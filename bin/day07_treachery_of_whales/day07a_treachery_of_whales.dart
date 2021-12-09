import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    var firstLine = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first;
    List<int> positions = firstLine.split(",").map(int.parse).toList();
    final result = bestPosition(positions);
    stdout.writeln(result.item1);
    stdout.writeln(result.item2);
  } catch (e) {
    stderr.addError(e);
  }
}

Tuple2<int, int> bestPosition(List<int> positions) {
  final uniquePositions = <int, int>{};
  int minPos = -1;
  int maxPos = -1;
  for(final pos in positions) {
    var count = uniquePositions[pos] ?? 0;
    uniquePositions[pos] = count + 1;
    if (minPos == -1) {
      minPos = pos;
      maxPos = pos;
      continue;
    }
    if (pos < minPos) {
      minPos = pos;
    } else if (pos > maxPos) {
      maxPos = pos;
    }
  }
  int bestPosition = -1;
  int bestMoveCost = -1;
  for(var toPos=minPos; toPos <= maxPos; toPos++) {
    final moveCost = moveCostSum(uniquePositions, toPos);
    if (bestPosition == -1 || moveCost < bestMoveCost) {
      bestPosition = toPos;
      bestMoveCost = moveCost;
    }
  }
  return Tuple2<int, int>(bestPosition, bestMoveCost);
}

int moveCostSum(Map<int, int> uniquePositions, int toPos) {
  var sum = 0;
  for(final posEntry in uniquePositions.entries) {
    final pos = posEntry.key;
    final count = posEntry.value;
    sum += (pos - toPos).abs() * count;
  }
  return sum;
}