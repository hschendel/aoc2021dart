import 'dart:math';
import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final cubeSet = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<CubeSet>(CubeSet(), (p, line) => p.parseLine(line));
    final onCubes = cubeSet.volume();
    stdout.writeln(onCubes);
  } catch (e) {
    stderr.addError(e);
  }
}

class CubeSet {
  var _cubes = <Cube>[]; // cubes in this list do never overlap

  CubeSet parseLine(String s, {Cube? initializationArea}) {
    if (s.startsWith("on ")) {
      final cube = Cube.fromString(s.substring("on ".length));
      if (initializationArea == null || initializationArea.contains(cube)) {
        add(cube);
      }
      return this;
    }
    if (s.startsWith("off ")) {
      final cube = Cube.fromString(s.substring("off ".length));
      if (initializationArea == null || initializationArea.contains(cube)) {
        remove(cube);
      }
      return this;
    }
    throw ArgumentError.value(s, "s", "must start with on or off");
  }

  void add(Cube addedCube) {
    _cubes = _allWithout(addedCube);
    _cubes.add(addedCube);
  }

  void remove(Cube removedCube) {
    _cubes = _allWithout(removedCube);
  }

  List<Cube> _allWithout(Cube removedCube) {
    final newCubes = <Cube>[];
    for(final cube in _cubes) {
      newCubes.addAll(cube.without(removedCube));
    }
    return newCubes;
  }

  int volume() => _cubes.fold<int>(0, (sum, cube) => sum + cube.volume);
}

class Cube {
  late final int minX;
  late final int maxX;
  late final int minY;
  late final int maxY;
  late final int minZ;
  late final int maxZ;

  static final _cubeRegExp = RegExp(r"^x=(\-?\d+)..(\-?\d+),y=(\-?\d+)..(\-?\d+),z=(\-?\d+)..(\-?\d+)$");

  Cube(this.minX, this.maxX, this.minY, this.maxY, this.minZ, this.maxZ);

  Cube.fromString(String s) {
    final match = _cubeRegExp.firstMatch(s);
    if (match == null) {
      throw ArgumentError.value(s, "s", "expected cube dimensions");
    }
    minX = int.parse(match.group(1)!);
    maxX = int.parse(match.group(2)!);
    minY = int.parse(match.group(3)!);
    maxY = int.parse(match.group(4)!);
    minZ = int.parse(match.group(5)!);
    maxZ = int.parse(match.group(6)!);
  }

  @override
  String toString() => "x=$minX..$maxX,y=$minY..$maxY,z=$minZ..$maxZ";

  @override
  bool operator ==(Object other) {
    if (other is! Cube) {
      return false;
    }
    return minX == other.minX && maxX == other.maxX
        && minY == other.minY && maxY == other.maxY
        && minZ == other.minZ && maxZ == other.maxZ;
  }

  int get xLength => maxX - minX + 1;
  int get yLength => maxY - minY + 1;
  int get zLength => maxZ - minZ + 1;
  int get volume => xLength * yLength * zLength;

  bool contains(Cube other) {
    return minX <= other.minX && other.maxX <= maxX
        && minY <= other.minY && other.maxY <= maxY
        && minZ <= other.minZ && other.maxZ <= maxZ;
  }

  Cube? intersect(Cube other) {
    final x1 = max(minX, other.minX);
    final x2 = min(maxX, other.maxX);
    if (x2 < x1) {
      return null;
    }
    final y1 = max(minY, other.minY);
    final y2 = min(maxY, other.maxY);
    if (y2 < y1) {
      return null;
    }
    final z1 = max(minZ, other.minZ);
    final z2 = min(maxZ, other.maxZ);
    if (z2 < z1) {
      return null;
    }
    return Cube(x1, x2, y1, y2, z1, z2);
  }

  Iterable<Cube> without(Cube other) sync* {
    final w = intersect(other);
    if (w == null) {
      yield this;
      return;
    }
    // we split up into up to 9 cubes including w, but do not add w to newCubes
    final newCubes = <Cube>[];
    for(var xt in <List<int>>[[minX,w.minX-1],[w.minX,w.maxX],[w.maxX+1,maxX]]) {
      if (xt[0] > xt[1]) {
        continue;
      }
      for(var yt in <List<int>>[[minY,w.minY-1],[w.minY,w.maxY],[w.maxY+1,maxY]]) {
        if (yt[0] > yt[1]) {
          continue;
        }
        for(var zt in <List<int>>[[minZ,w.minZ-1],[w.minZ,w.maxZ],[w.maxZ+1,maxZ]]) {
          if (zt[0] > zt[1]) {
            continue;
          }
          final cube = Cube(xt[0],xt[1],yt[0],yt[1],zt[0],zt[1]);
          if (cube != w) {
            yield cube;
          }
        }
      }
    }
  }
}
