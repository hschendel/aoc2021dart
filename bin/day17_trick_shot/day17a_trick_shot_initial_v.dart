import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final g = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((s) => TargetArea.fromString(s))
        .forEach((a) {
          final best = a.bestVelocityWithPeakY();
          final sol = best == null ? "no solution" : "(${best.item1},${best.item2}) with peak y = ${best.item3} after ${best.item4} steps";
          stdout.writeln("$a => $sol");
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
    maxX = max(x1,x2);
    minY = min(y1,y2);
    maxY = max(y1,y2);
  }

  @override
  String toString() => "target area: x=$minX..$maxX, y=$minY..$maxY";

  Tuple2<int, int>? xvRange() {
    var xv = 1;
    int? av;
    int bv = 0;
    while (true) {
      final x = xAtStep(xv, xv);
      if (x > maxX) {
        break;
      }
      if (av == null && x >= minX) {
        av = xv;
      }
      if (x >= minX) {
        bv = xv;
      }
      xv++;
    }
    if (av == null) {
      return null;
    }
    return Tuple2(av, bv);
  }

  // only valid while n <= xv
  static int xAtStep(int n, int xv) => n * xv - n * (n-1) ~/2;

  static int yAtStep(int n, int yv) => n * yv - n * (n-1) ~/2;

  static int peakY(int steps, int yv) {
    var peakY = -(1 << 32);
    for(var n=1; n <= steps; n++) {
      final y = yAtStep(n, yv);
      if (y > peakY) {
        peakY = y;
      }
    }
    return peakY;
  }

  Tuple3<int, int, int>? bestYVwithPeakYAndNFor(int xv) {
    int yv = -minY - 1;
    int firstEndY = -(1 << 32);
    while (firstEndY < maxY) {
      yv++;
      firstEndY = yAtStep(xv, yv);
    }
    int bestPeakY = -(1 << 32);
    int? bestYV;
    int? bestN;
    for(;firstEndY >= minY; yv--) {
      var n = xv;
      firstEndY = yAtStep(xv, yv);
      for(var endY = firstEndY; endY >= minY; endY = yAtStep(++n, yv)) {
        if (minY <= endY && endY <= maxY) {
          final py = peakY(n, yv);
          if (bestYV == null || py > bestPeakY) {
            bestYV = yv;
            bestPeakY = py;
            bestN = n;
          }
        }
      }
    }
    if (bestYV == null) {
      return null;
    }
    return Tuple3(bestYV, bestPeakY, bestN!);
  }

  Tuple4<int, int, int, int>? bestVelocityWithPeakY() {
    final xvr = xvRange();
    if (xvr == null) {
      return null;
    }
    int? bestXV;
    int? bestN;
    int bestYV = 0;
    int bestPY = -(1 << 32);
    for (var n=xvr.item2; n >= xvr.item1; n--) {
      final yvPyN = bestYVwithPeakYAndNFor(n);
      if (yvPyN == null) {
        continue;
      }
      if (bestXV == null || yvPyN.item2 > bestPY) {
        bestXV = n;
        bestYV = yvPyN.item1;
        bestPY = yvPyN.item2;
        bestN = yvPyN.item3;
      }
    }
    if (bestXV == null) {
      return null;
    }
    return Tuple4(bestXV, bestYV, bestPY, bestN!);
  }
}