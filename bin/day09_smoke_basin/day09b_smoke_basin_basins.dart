import 'dart:io';
import 'dart:convert';

import 'dart:math';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);

  try {
    final basinMap = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<BasinMap>(BasinMap(), (bm, s) => bm.addRow(s));
    final result = basinMap.threeLargestBasinSizesProduct();
    stdout.writeln(result);
  } catch (e) {
    stderr.addError(e);
  }
}

class BasinMap {
  final map = <List<_Location>>[];
  static final int _code0 = "0".runes.first;

  BasinMap addRow(String s) {
    map.add(s.runes.map((ch) => _Location(ch - _code0)).toList());
    return this;
  }

  bool hasLocation(int x, int y) {
    if (y >= map.length || y < 0) {
      return false;
    }
    final row = map[y];
    if (x >= row.length || x < 0) {
      return false;
    }
    return true;
  }

  bool isLowPoint(int x, int y) {
    final v = map[y][x].height;
    if (hasLocation(x-1, y) && map[y][x-1].height <= v) {
      return false;
    }
    if (hasLocation(x+1, y) && map[y][x+1].height <= v) {
      return false;
    }
    if (hasLocation(x, y-1) && map[y-1][x].height <= v) {
      return false;
    }
    if (hasLocation(x, y+1) && map[y+1][x].height <= v) {
      return false;
    }
    return true;
  }

  int markBasin(int x, int y, int basinNo, int minHeight) {
    final v = map[y][x].height;
    if (v >= 9 || v < minHeight || map[y][x].basin != 0) {
      return 0;
    }
    var basinSize = 1;
    map[y][x].basin = basinNo;
    if (hasLocation(x-1, y)) {
      basinSize += markBasin(x-1, y, basinNo, v);
    }
    if (hasLocation(x+1, y)) {
      basinSize += markBasin(x+1, y, basinNo, v);
    }
    if (hasLocation(x, y-1)) {
      basinSize += markBasin(x, y-1, basinNo, v);
    }
    if (hasLocation(x, y+1)) {
      basinSize += markBasin(x, y+1, basinNo, v);
    }
    return basinSize;
  }

  List<Point<int>> lowPoints() {
    final points = <Point<int>>[];
    for(var y = 0; y < map.length; y++) {
      final row = map[y];
      for (var x = 0; x < row.length; x++) {
        if (isLowPoint(x, y)) {
          points.add(Point(x,y));
        }
      }
    }
    return points;
  }

  List<int> basinSizes() {
    var basinNo = 0;
    return lowPoints().map((p) => markBasin(p.x, p.y, ++basinNo, map[p.y][p.x].height)).toList();
  }

  int threeLargestBasinSizesProduct() {
    final sizes = basinSizes();
    sizes.sort();
    return sizes.reversed.take(3).fold(1, (product, size) => product * size);
  }
}

class _Location {
  int height;
  int basin = 0;

  _Location(this.height);
}
