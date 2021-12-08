import 'dart:io';
import 'dart:convert';

import 'dart:math';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    var lines = await file.openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .fold<List<Line>>(<Line>[], (lines, lineStr) {
        final line = Line.parse(lineStr);
        lines.add(line);
        return lines;
      });
    lines = lines.where((line) => line.isHorizontal || line.isVertical).toList();
    final points = intersectionPoints(lines);
    stdout.writeln(points.length);
  } catch (e) {
    stderr.addError(e);
  }
}

Set<Point<int>> intersectionPoints(List<Line> lines) {
  final points = <Point<int>>{};
  final addedLines = <Line>[];
  for(final line in lines) {
    for (final otherLine in addedLines) {
      points.addAll(line.intersect(otherLine));
    }
    addedLines.add(line);
  }
  return points;
}

class Line {
  final Point<int> a;
  final Point<int> b;

  Line(this.a, this.b);

  List<Point<int>> intersect(Line other) {
    if (isHorizontal && other.isHorizontal) {
      if (a.y != other.a.y) {
        return [];
      }
      final startX = max(other.minX, minX);
      final stopX = min(other.maxX, maxX);
      final intersection = <Point<int>>[];
      for (var x = startX; x <= stopX; x++) {
        intersection.add(Point(x, a.y));
      }
      return intersection;
    } else if (isVertical && other.isVertical) {
      if (a.x != other.a.x) {
        return [];
      }
      final startY = max(other.minY, minY);
      final stopY = min(other.maxY, maxY);
      final intersection = <Point<int>>[];
      for (var y = startY; y <= stopY; y++) {
        intersection.add(Point(a.x, y));
      }
      return intersection;
    } else if (isVertical && other.isHorizontal) {
      final p = Point(a.x, other.a.y);
      if (other.minX <= p.x && p.x <= other.maxX && minY <= p.y && p.y <= maxY) {
        return [p];
      }
      return [];
    } else if (isHorizontal && other.isVertical) {
      final p = Point(other.a.x, a.y);
      if (minX <= p.x && p.x <= maxX && other.minY <= p.y && p.y <= other.maxY) {
        return [p];
      }
      return [];
    } else {
      if (!isVertical && !isHorizontal) {
        throw UnimplementedError("line is not horizontal or vertical: $this");
      }
      throw UnimplementedError("line is not horizontal or vertical: $other");
    }
  }

  bool get isVertical => a.x == b.x;
  bool get isHorizontal => a.y == b.y;
  int get minX => min(a.x, b.x);
  int get maxX => max(a.x, b.x);
  int get minY => min(a.y, b.y);
  int get maxY => max(a.y, b.y);

  @override
  String toString() {
    return "${a.x},${a.y} -> ${b.x},${b.y}";
  }

  static final _parseRegExp = RegExp(r"^\s*(\d+)\s*,\s*(\d+)\s*\->\s*(\d+)\s*,\s*(\d+)\s*$");

  static Line parse(String s) {
    final match = _parseRegExp.firstMatch(s);
    if (match == null) {
      throw FormatException("not a valid line", s);
    }
    final ax = int.parse(match.group(1)!);
    final ay = int.parse(match.group(2)!);
    final bx = int.parse(match.group(3)!);
    final by = int.parse(match.group(4)!);
    return Line(Point(ax,ay), Point(bx,by));
  }
}