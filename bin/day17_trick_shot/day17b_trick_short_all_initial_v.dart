import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((s) => TargetArea.fromString(s))
        .forEach((a) {
      final count = a.initialVelocities().length;
      a.initialVelocities().forEach((v) { stdout.writeln(v); });
      stdout.writeln("$a => $count initial velocities");
    });
  } catch (e) {
    stderr.addError(e);
  }
}

class TargetArea {
  late final int minX;
  late final int maxX;
  late final int minY;
  late final int maxY;

  static final _parseRegExp = RegExp(r"^target area: x=(\d+)..(\d+), y=(\-\d+)..(\-\d+)");

  TargetArea.fromString(String s) {
    final match = _parseRegExp.firstMatch(s);
    if (match == null) {
      throw ArgumentError.value(s, "s", "not a valid target area expression");
    }
    final x1 = int.parse(match.group(1)!);
    final x2 = int.parse(match.group(2)!);
    final y1 = int.parse(match.group(3)!);
    final y2 = int.parse(match.group(4)!);
    minX = min(x1,x2);
    if (minX <= 0) {
      throw ArgumentError.value(s, "s", "the x range must be larger than 0.");
    }
    maxX = max(x1,x2);
    minY = min(y1,y2);
    maxY = max(y1,y2);
  }

  @override
  String toString() => "target area: x=$minX..$maxX, y=$minY..$maxY";

  List<int> initialYVelocities() {
    final yvs = <int>[];
    for(var yv = -minY + 1; yv > minY - 1; yv--) {
      for(var v=yv, y=0; y >= minY; y += v, v--) {
        if (minY <= y && y <= maxY) {
          yvs.add(yv);
          break;
        }
      }
    }
    return yvs;
  }

  List<int> initialXVelocities() {
    final xvs = <int>[];
    for(var xv = 1; xv <= maxX; xv++) {
      for(var v=xv, x=0; x <= maxX && v > 0; x += v, v--) {
        if (minX <= x && x <= maxX) {
          xvs.add(xv);
          break;
        }
      }
    }
    return xvs;
  }

  List<Velocity> initialVelocities() {
    final vs = <Velocity>[];
    for(final xv in initialXVelocities()) {
      for(final yv in initialYVelocities()) {
        for(var x=0, y=0, vx=xv, vy=yv; y >= minY && x <= maxX; x += vx, y += vy, vx = (vx == 0 ? 0 : vx-1), vy--) {
          if (minX <= x && x <= maxX && minY <= y && y <= maxY) {
            vs.add(Velocity(xv, yv));
            break;
          }
        }
      }
    }
    vs.sort();
    return vs;
  }
}

class Velocity implements Comparable<Velocity> {
  final int xv;
  final int yv;

  Velocity(this.xv, this.yv);

  @override
  String toString() => "($xv,$yv)";

  @override
  int compareTo(Velocity other) {
    final xc = xv.compareTo(other.xv);
    if (xc != 0) {
      return xc;
    }
    return yv.compareTo(other.yv);
  }

}