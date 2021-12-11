import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  final code0 = "0".runes.first;
  try {
    var rows = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => line.runes.map((ch) => ch - code0).toList())
        .toList();
    var riskLevel = 0;
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        if (isLowPoint(rows, x, y)) {
          riskLevel += 1 + row[x];
        }
      }
    }
    stdout.writeln(riskLevel);
  } catch (e) {
    stderr.addError(e);
  }
}

bool isLowPoint(List<List<int>> rows, int x, int y) {
  final v = rows[y][x];
  if (x > 0 && rows[y][x-1] <= v) {
    return false;
  }
  if (rows[y].length > (x+1) && rows[y][x+1] <= v) {
    return false;
  }
  if (y > 0 && rows[y].length > x && rows[y-1][x] <= v) {
    return false;
  }
  if (rows.length > (y+1) && rows[y+1].length > x && rows[y+1][x] <= v) {
    return false;
  }
  return true;
}