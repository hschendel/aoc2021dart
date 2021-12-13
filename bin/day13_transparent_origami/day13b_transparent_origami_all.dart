import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final sys = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<FoldingCoordinateSystem>(FoldingCoordinateSystem(), (sys, line) => sys.parseLine(line));
    sys.dump();
  } catch (e) {
    stderr.addError(e);
  }
}

class FoldingCoordinateSystem {
  var _maxX = 0;
  var _maxY = 0;
  var _dots = <Point<int>>{};
  bool _parseDots = true;

  static final _parseDotRegExp = RegExp(r"^(\d+),(\d+)$");
  static final _foldRegExp = RegExp(r"^fold along (x|y)\=(\d+)$");

  int get dotCount => _dots.length;

  FoldingCoordinateSystem parseLine(String s) {
    if (_parseDots) {
      _parseDotLine(s);
    } else {
      _parseFoldLine(s);
    }
    return this;
  }

  void _parseDotLine(String s) {
    if (s.isEmpty) {
      _parseDots = false;
      return;
    }
    final match = _parseDotRegExp.firstMatch(s);
    if (match == null) {
      throw ArgumentError.value(s, "s", "expected dot, e.g. 1,2");
    }
    final dot = Point(int.parse(match.group(1)!), int.parse(match.group(2)!));
    _dots.add(dot);
    _maxX = max(_maxX, dot.x);
    _maxY = max(_maxY, dot.y);
    return;
  }

  void _parseFoldLine(String s) {
    final match = _foldRegExp.firstMatch(s);
    if (match == null) {
      throw ArgumentError.value(s, "s", "expected fold, e.g. fold along y=27");
    }
    final axis = match.group(1);
    final axisValue = int.parse(match.group(2)!);
    if (axis == "x") {
      foldAlongX(axisValue);
    } else {
      foldAlongY(axisValue);
    }
  }

  void foldAlongX(int x) {
    if (_maxX < x) {
      return;
    }
    final newDots = <Point<int>>{};
    var xShift = 0;
    final x2 = x * 2;
    final maxDiff = x2 - _maxX;
    if (maxDiff < 0) {
      xShift = maxDiff.abs();
    }
    var newMaxX = 0;
    var newMaxY = 0;
    for(var dot in _dots) {
      if (dot.x == x) {
        continue;
      }
      if (dot.x > x) {
        dot = Point(x2 - dot.x + xShift, dot.y);
      } else {
        dot = Point(dot.x + xShift, dot.y);
      }
      newDots.add(dot);
      newMaxX = max(newMaxX, dot.x);
      newMaxY = max(newMaxY, dot.y);
    }
    _dots = newDots;
    _maxX = newMaxX;
    _maxY = newMaxY;
  }

  void foldAlongY(int y) {
    if (_maxY < y) {
      return;
    }
    final newDots = <Point<int>>{};
    var yShift = 0;
    final y2 = y * 2;
    final maxDiff = y2 - _maxY;
    if (maxDiff < 0) {
      yShift = maxDiff.abs();
    }
    var newMaxX = 0;
    var newMaxY = 0;
    for(var dot in _dots) {
      if (dot.y == y) {
        continue;
      }
      if (dot.y > y) {
        dot = Point(dot.x, y2 - dot.y + yShift);
      } else {
        dot = Point(dot.x, dot.y + yShift);
      }
      newDots.add(dot);
      newMaxX = max(newMaxX, dot.x);
      newMaxY = max(newMaxY, dot.y);
    }
    _dots = newDots;
    _maxX = newMaxX;
    _maxY = newMaxY;
  }

  void dump() {
    final sb = StringBuffer();
    for(var y = 0; y <= _maxY; y++) {
      for(var x = 0; x <= _maxX; x++) {
        if (_dots.contains(Point(x,y))) {
          sb.write("#");
        } else {
          sb.write(".");
        }
      }
      sb.writeln();
    }
    stdout.write(sb.toString());
  }
}
