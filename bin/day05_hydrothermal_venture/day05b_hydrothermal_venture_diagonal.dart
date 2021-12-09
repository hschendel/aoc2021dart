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
      final intersection = line.intersect(otherLine);
      for (final p in intersection) {
        if (p.x == 2 && p.y == 0) {
          stdout.writeln("(2,0) said to be intersection of $line and $otherLine");
        }
      }
      points.addAll(intersection);
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
    if(maxX < other.minX || other.maxX < minX || maxY < other.minY || other.maxY < minY) {
      return [];
    }
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
    } else if (isDiagonal && other.isVertical) {
      final py = yAtX(other.a.x);
      if (py == null || py < other.minY || other.maxY < py) {
        return [];
      }
      return [Point(other.a.x, py)];
    } else if (isVertical && other.isDiagonal) {
      final py = other.yAtX(a.x);
      if (py == null || py < minY || maxY < py) {
        return [];
      }
      return [Point(a.x, py)];
    } else if (isDiagonal && other.isHorizontal) {
      final px = xAtY(other.a.y);
      if (px == null || px < other.minX || other.maxX < px) {
        return [];
      }
      return [Point(px, other.a.y)];
    } else if (isHorizontal && other.isDiagonal) {
      final px = other.xAtY(a.y);
      if (px == null || px < minX || maxX < px) {
        return [];
      }
      return [Point(px, a.y)];
    } else if (isDiagonal && other.isDiagonal) {
      final startX = max(minX, other.minX);
      final stopX = min(maxX, other.maxX);
      // no time for proper geometric calculation also detecting
      // overlapping or parallel lines, therefore brute force
      final intersection = <Point<int>>[];
      for (var x = startX; x <= stopX; x++) {
        final yt = yAtX(x);
        final yo = other.yAtX(x);
        if (yt == null || yo == null || yt != yo) {
          continue;
        }
        intersection.add(Point(x,yt));
      }
      return intersection;
    } else {
      if (!isVertical && !isHorizontal && !isDiagonal) {
        throw UnimplementedError("line is not horizontal, vertical, or diagonal: $this");
      }
      throw UnimplementedError("line is not horizontal, vertical, or diagonal: $other");
    }
  }

  bool get isVertical => a.x == b.x;
  bool get isHorizontal => a.y == b.y;
  bool get isDiagonal => (right.x - left.x) == (bottom.y - top.y);
  int get minX => min(a.x, b.x);
  int get maxX => max(a.x, b.x);
  int get minY => min(a.y, b.y);
  int get maxY => max(a.y, b.y);
  Point<int> get left => a.x <= b.x ? a : b;
  Point<int> get right => a.x <= b.x ? b : a;
  Point<int> get top => a.y <= b.y ? a : b;
  Point<int> get bottom => a.y <= b.y ? b: a;

  int get _coeffX1 {
    if (isHorizontal) {
      return 0;
    }
    if (isDiagonal) {
      if (left.y < right.y) {
        return 1;
      } else {
        return -1;
      }
    }
    throw UnimplementedError("not implemented for not diagonal or horizontal");
  }

  int get _coeffX2 {
    return left.y - _coeffX1 * left.x;
  }

  int get _coeffY1 {
    if (isVertical) {
      return 0;
    }
    if (isDiagonal) {
      if (top.x < bottom.x) {
        return 1;
      } else {
        return -1;
      }
    }
    throw UnimplementedError("not implemented for not diagonal or vertical");
  }

  int get _coeffY2 {
    return top.x - _coeffY1 * top.y;
  }

  int? yAtX(int x) {
    if (x < minX || maxX < x) {
      return null;
    }
    if (isVertical) {
      return null;
    }
    final c1 = _coeffX1;
    final c1x = c1 * x;
    final c2 = _coeffX2;
    final c1xPlusC2 = c1x + c2;
    return c1xPlusC2;
  }

  int? xAtY(int y) {
    if (y < minY || maxY < y) {
      return null;
    }
    if (isHorizontal) {
      return null;
    }
    return _coeffY1 * y + _coeffY2;
  }

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