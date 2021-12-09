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
    final result = dumbBestPosition(positions);
    stdout.writeln(result.item1);
    stdout.writeln(result.item2);
  } catch (e) {
    stderr.addError(e);
  }
}

Tuple2<int, int> dumbBestPosition(List<int> positions) {
  int bestPosition = -1;
  int bestMoveCost = -1;
  for(final toPos in positions) {
    final moveCost = moveCostSum(positions, toPos);
    if (bestPosition == -1 || moveCost < bestMoveCost) {
      bestPosition = toPos;
      bestMoveCost = moveCost;
    }
  }
  return Tuple2<int, int>(bestPosition, bestMoveCost);
}

int moveCostSum(List<int> positions, int toPos) {
  var sum = 0;
  for(final pos in positions) {
    sum += (pos - toPos).abs();
  }
  return sum;
}