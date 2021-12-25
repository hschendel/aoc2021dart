
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final report = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<Report>(Report(), (r, line) => r.parseLine(line));
    final highestDist = report.merge();
    stdout.writeln(highestDist);
  } catch (e) {
    stderr.addError(e);
  }
}

class Report {
  final scanners = <Set<Point3>>[];
  var _parseMode = 0;
  final _scannerPos = <Point3>{};

  static final _scannerHeadRegExp = RegExp(r"^--- scanner (\d+) ---$");

  Report parseLine(String s) {
    switch (_parseMode) {
      case 0:
        final match = _scannerHeadRegExp.firstMatch(s);
        if (match == null) {
          throw ArgumentError.value(s, "s", "expected scanner head line");
        }
        scanners.add({});
        _parseMode = 1;
        return this;
      default:
        if (s.isEmpty) {
          _parseMode = 0;
          return this;
        }
        final p = Point3.parse(s);
        scanners.last.add(p);
        return this;
    }
  }

  int merge() {
    _scannerPos.clear();
    _scannerPos.add(Point3(0,0,0));
    if (scanners.length <= 1) {
      return 0;
    }
    var merged = true;
    while(merged) {
      merged = false;
      for(var j=1; j < scanners.length; j++) {
        final ms = tryMerge(scanners[0], scanners[j]);
        if (ms == null) {
          continue;
        }
        scanners[0] = ms.item1;
        scanners.removeAt(j);
        _scannerPos.add(ms.item2);
        merged = true;
        break;
      }
    }
    if (scanners.length != 1) {
      throw UnsupportedError("cannot merge all");
    }
    return highestScannerPosDist();
  }

  int highestScannerPosDist() {
    int maxDist = 0;
    for(var p1 in _scannerPos) {
      for(var p2 in _scannerPos) {
        maxDist = max(maxDist, p1.manhattanDistance(p2));
      }
    }
    return maxDist;
  }

  static Tuple2<Set<Point3>, Point3>? tryMerge(Set<Point3> base, Iterable<Point3> other, {int threshold = 12}) {
    for(final otherRotated in Rotation3.all.map((r) => other.map((p) => p.rotate(r)))) {
      for(final bp in base) {
        for(final op in otherRotated) {
          final d = bp.sub(op);
          final otherRotatedAndShifted = otherRotated.map((p) => p.add(d));
          if (_match(base, otherRotatedAndShifted, threshold: threshold)) {
            final r = <Point3>{};
            r.addAll(base);
            r.addAll(otherRotatedAndShifted);
            return Tuple2(r, Point3(0,0,0).add(d));
          }
        }
      }
    }
    return null;
  }

  static bool _match(Set<Point3> base, Iterable<Point3> other, {int threshold = 12}) {
    var matches = 0;
    for(final op in other) {
      if (base.contains(op)) {
        matches++;
        if (matches >= threshold) {
          return true;
        }
      }
    }
    return false;
  }
}

class Point3 {
  final int x;
  final int y;
  final int z;

  Point3(this.x, this.y, this.z);

  static Point3 parse(String s) {
    final vals = s.split(",").map(int.parse).toList();
    if (vals.length != 3) {
      throw ArgumentError.value(s, "s", "expected three integers");
    }
    return Point3(vals[0], vals[1], vals[2]);
  }

  @override
  String toString() {
    return "$x,$y,$z";
  }

  Point3 rotate(Rotation3 rot) {
    var nx = x;
    var ny = y;
    var nz = z;

    switch (rot.xTurns) {
      case 1: final ty = ny; ny = nz; nz = -ty; break;
      case 2: ny = -ny; nz = -nz; break;
      case 3: final ty = ny; ny = -nz; nz = ty; break;
    }

    switch (rot.yTurns) {
      case 1: final tx = nx; nx = nz; nz = -tx; break;
      case 2: nx = -nx; nz = -nz; break;
      case 3: final tx = nx; nx = -nz; nz = tx; break;
    }

    switch (rot.zTurns) {
      case 1: final tx = nx; nx = ny; ny = -tx; break;
      case 2: nx = -nx; ny = -ny; break;
      case 3: final tx = nx; nx = -ny; ny = tx; break;
    }

    return Point3(nx, ny, nz);
  }

  Point3 add(Point3 other) {
    return Point3(x + other.x, y + other.y, z + other.z);
  }

  Point3 sub(Point3 other) {
    return Point3(x - other.x, y - other.y, z - other.z);
  }

  int manhattanDistance(Point3 other) => (other.x - x).abs() + (other.y - y).abs() + (other.z - z).abs();

  @override
  bool operator ==(Object other) {
    if (other is! Point3) {
      return false;
    }
    return x == other.x && y == other.y && z == other.z;
  }

  @override
  int get hashCode => (x.abs() << 42) | (y.abs() << 21) | z.abs();

}

class Rotation3 {
  final int xTurns;
  final int yTurns;
  final int zTurns;

  Rotation3(this.xTurns, this.yTurns, this.zTurns);

  static Iterable<Rotation3> get all sync* {
    for(var xt = 0; xt < 4; xt++) {
      for(var yt = 0; yt < 4; yt++) {
        for(var zt = 0; zt < 4; zt++) {
          yield Rotation3(xt, yt, zt);
        }
      }
    }
  }
}