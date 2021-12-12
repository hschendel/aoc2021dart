import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final grid = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<OctopusGrid>(OctopusGrid(), (grid, line) => grid.addLine(line));
    final stepNo = grid.runUntilAllFlash();
    stdout.writeln(stepNo);
  } catch (e) {
    stderr.addError(e);
  }
}

class OctopusGrid {
  final grid = <List<int>>[];
  static final int _code0 = "0".runes.first;

  OctopusGrid addLine(String s) {
    if (grid.length >= 10) {
      return this;
    }
    if (s.length != 10) {
      throw ArgumentError.value(s, "s", "length is not 10");
    }
    final row = <int>[];
    for(var i=0; i < 10; i++) {
      final ch = s[i];
      final v = ch.runes.first - _code0;
      if (v < 0 || v > 9) {
        throw ArgumentError.value(s, "s", "illegal character '$ch'");
      }
      row.add(v);
    }
    grid.add(row);
    return this;
  }

  /// runs steps until all have flashed in one step
  /// returns number of step at end
  int runUntilAllFlash() {
    var allHaveFlashed = false;
    var stepNo = 0;
    while (!allHaveFlashed) {
      stepNo++;
      allHaveFlashed = step();
    }
    return stepNo;
  }

  /// runs a step
  /// returns true if all octopuses have flashed in this step
  bool step() {
    increment();
    var flashCount = 0;
    Tuple3<int, bool, bool> t;
    do {
      t = flashRound();
      flashCount += t.item1;
    } while(t.item2);
    return t.item3;
  }

  void increment() {
    for(var y=0; y < grid.length; y++) {
      for(var x=0; x < grid[y].length; x++) {
        grid[y][x]++;
      }
    }
  }

  /// flashes all octopuses > 9
  /// First tuple value is flash count
  /// Second value is true if flashing caused another octopus to exceed 9
  /// Third value is true if all values are zero after this round
  Tuple3<int, bool, bool> flashRound() {
    var otherExceeded9 = false;
    var flashCount = 0;
    var allZero = true;
    for(var y=0; y < grid.length; y++) {
      for(var x=0; x < grid[y].length; x++) {
        if(grid[y][x] > 9) {
          otherExceeded9 |= flash(x, y);
          flashCount++;
        } else if (grid[y][x] != 0) {
          allZero = false;
        }
      }
    }
    return Tuple3(flashCount, otherExceeded9, allZero);
  }

  /// returns true if a neighbour has exceeded 9
  bool flash(int x, int y) {
    grid[y][x] = 0;
    var neighbourAbove9 = false;
    for(final np in neighbours(x, y)) {
      if (grid[np.y][np.x] == 0) {
        continue; // has already flashed
      }
      grid[np.y][np.x]++;
      if (grid[np.y][np.x] > 9) {
        neighbourAbove9 = true;
      }
    }
    return neighbourAbove9;
  }

  Iterable<Point<int>> neighbours(int x, int y) sync* {
    for(var nx=x-1; nx <= x+1; nx++) {
      for(var ny=y-1; ny <= y+1; ny++) {
        if (nx < 0 || ny < 0 || nx == x && ny == y || ny >= grid.length || nx >= grid[ny].length) {
          continue;
        }
        yield Point(nx, ny);
      }
    }
  }
}