import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final g = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<Graph>(Graph(), (g, line) => g.parseLine(line));
    g.expand();
    final bestPathRisk = aStarLowestCost(g);
    stdout.writeln(bestPathRisk);
  } catch (e) {
    stderr.addError(e);
  }
}

int aStarLowestCost(Graph g) {
  const infinity = 1 << 32;
  final h = (from) => g.stepsBetween(from, g.end);

  final cameFrom = <Point<int>, Point<int>>{};
  final gScore = <Point<int>,int>{g.start: 0};
  final fScore = <Point<int>,int>{g.start: h(g.start)};
  final openSet = HeapPriorityQueue<Point<int>>((a,b) => (fScore[a] ?? infinity) - (fScore[b] ?? infinity));
  openSet.add(g.start);
  while (openSet.isNotEmpty) {
    final current = openSet.first;
    if (current == g.end) {
      return gScore[current]!;
    }
    openSet.remove(current);
    for(final edge in g.edgesFrom(current)) {
      final tentativeGScore = gScore[current]! + edge.cost;
      if (tentativeGScore < (gScore[edge.to] ?? infinity)) {
        cameFrom[edge.to] = current;
        gScore[edge.to] = tentativeGScore;
        fScore[edge.to] = tentativeGScore + h(edge.to);
        if (!openSet.contains(edge.to)) {
          openSet.add(edge.to);
        }
      }
    }
  }

  return -1;
}

class Graph {
  var _map = <List<int>>[];

  static final _code1 = "1".runes.first;

  Graph parseLine(String s) {
    final row = <int>[];
    for(final r in s.runes) {
      final value = r - _code1 + 1;
      if (value < 1 || value > 9) {
        throw ArgumentError.value(s, "s", "invalid character '${String.fromCharCode(r)}'");
      }
      row.add(value);
    }
    _map.add(row);
    return this;
  }

  Iterable<Edge> edgesFrom(Point<int> node) sync* {
    if ((node.y + 1) < _map.length && (node.x < _map[node.y + 1].length)) {
      yield Edge(Point(node.x, node.y + 1), _map[node.y + 1][node.x]);
    }
    if ((node.y) < _map.length && ((node.x + 1) < _map[node.y].length)) {
      yield Edge(Point(node.x + 1, node.y), _map[node.y][node.x + 1]);
    }
    if (node.x > 0 && (node.y) < _map.length && ((node.x - 1) < _map[node.y].length)) {
      yield Edge(Point(node.x - 1, node.y), _map[node.y][node.x - 1]);
    }
    if (node.y > 0 && (node.y - 1) < _map.length && (node.x < _map[node.y - 1].length)) {
      yield Edge(Point(node.x, node.y - 1), _map[node.y - 1][node.x]);
    }
  }

  Point<int> get start => Point(0, 0);
  Point<int> get end => Point(_map.last.length-1, _map.length-1);

  int stepsBetween(Point from, Point to) {
    return (to.y-from.y).abs().toInt() + (to.x-from.x).abs().toInt();
  }

  void expand() {
    final oldWidth = _map.length;
    final oldHeight = _map.last.length;
    final eMap = <List<int>>[];
    final newHeight = oldWidth * 5;
    final newWidth = oldHeight * 5;

    for(var y = 0; y < newHeight; y++) {
      final yAdd = y ~/ oldHeight;
      final oldY = y % oldHeight;
      final row = <int>[];
      for (var x = 0; x < newWidth; x ++) {
        final xAdd = x ~/ oldWidth;
        final oldX = x % oldWidth;
        row.add((_map[oldY][oldX] - 1 + yAdd + xAdd) % 9 + 1);
      }
      eMap.add(row);
    }

    _map = eMap;
  }
}

class Edge {
  final Point<int> to;
  final int cost;

  Edge(this.to, this.cost);
}