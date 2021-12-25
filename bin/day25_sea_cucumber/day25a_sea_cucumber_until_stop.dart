import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final floor = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<SeaFloor>(SeaFloor(), (floor, line) => floor.parseRow(line));
    final stepsToStop = floor.runUntilStop();
    stdout.writeln(stepsToStop);
  } catch (e) {
    stderr.addError(e);
  }
}

class SeaFloor {
  final _m = <List<String>>[];

  int get height => _m.length;
  int get width => height > 0 ? _m.first.length : 0;
  String at(int x, int y) => _m[y % height][x % width];
  void set(int x, int y, String ch) {
    _m[y % height][x % width] = ch;
  }

  SeaFloor parseRow(String s) {
    _m.add(s.runes.map((r) => String.fromCharCode(r)).toList());
    return this;
  }

  int runUntilStop() {
    var moved = true;
    var steps = 0;
    while(moved) {
      steps++;
      moved = step();
    }
    return steps;
  }

  bool step() {
    var moved = moveHerd(">", 1, 0);
    moved |= moveHerd("v", 0, 1);
    return moved;
  }

  bool moveHerd(String herd, int dx, int dy) {
    final moveList = <Point<int>>[];
    for(var y=0; y < height; y++) {
      for(var x=0; x < width; x++) {
        if (at(x,y) != herd) {
          continue;
        }
        final nx = x + dx;
        final ny = y + dy;
        if (at(nx,ny) == ".") {
          moveList.add(Point(x,y));
        }
      }
    }
    for (final p in moveList) {
      final herd = at(p.x, p.y);
      set(p.x, p.y, ".");
      set(p.x + dx, p.y + dy, herd);
    }
    return moveList.isNotEmpty;
  }
}