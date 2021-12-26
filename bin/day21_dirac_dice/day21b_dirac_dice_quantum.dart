import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:tuple/tuple.dart';

const trackLen = 10;
const winScore = 21;

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final parser = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<Parser>(Parser(), (p, line) => p.parseLine(line));
    final game = QuantumGame(parser.startPos[0], parser.startPos[1]);
    final output = game.run();
    stdout.writeln(output);
  } catch (e) {
    stderr.addError(e);
  }
}

class Parser {
  var player = 0;
  final startPos = <int>[];

  Parser parseLine(String s) {
    final expectedPrefix = "Player ${player+1} starting position: ";
    if (!s.startsWith(expectedPrefix)) {
      throw ArgumentError.value(s, "s", "expected starting position for player ${player+1}");
    }
    var pos = int.parse(s.substring(expectedPrefix.length)) - 1; // starts at 0 internally
    startPos.add(pos);
    player++;
    return this;
  }
}

class QuantumGame {
  var _counts = <CountKey, int>{}; // universes by position and score

  QuantumGame(int pos1, int pos2) {
    final key = CountKey(pos1, pos2, 0, 0);
    _counts[key] = 1;
  }

  int run() {
    for(var player1 = true, finished=false; !finished; player1 = !player1) {
      finished = turn(player1);
    }
    final wins = playerWins();
    return max(wins.item1, wins.item2);
  }

  bool turn(bool player1) {
    final newCounts = <CountKey, int>{};
    var allFinished = true;
    for(final e in _counts.entries) {
      if (e.key.finished) {
        newCounts[e.key] = (newCounts[e.key] ?? 0) + e.value;
        continue;
      }
      allFinished = false;
      for(final t3 in Throw3Count.all) {
        final newKey = e.key.withThrow3(player1, t3);
        newCounts[newKey] = (newCounts[newKey] ?? 0) + e.value * t3.count;
      }
    }
    _counts = newCounts;
    return allFinished;
  }

  Tuple2<int, int> playerWins() {
    int wins1 = 0;
    int wins2 = 0;
    for(final e in _counts.entries) {
      if (e.key.isWin1) {
        wins1 += e.value;
      }
      if (e.key.isWin2) {
        wins2 += e.value;
      }
    }
    return Tuple2(wins1, wins2);
  }
}

class Throw3Count {
  final int sum;
  final int count;

  Throw3Count(this.sum, this.count);

  // all possible score sums and their number of occurences = universes
  // from throwing three dice
  static final all = <Throw3Count>[
    Throw3Count(3, 1),
    Throw3Count(4, 3),
    Throw3Count(5, 6),
    Throw3Count(6, 7),
    Throw3Count(7, 6),
    Throw3Count(8, 3),
    Throw3Count(9, 1)
  ];
}

class CountKey {
  final int _key;

  CountKey(int pos1, int pos2, int score1, int score2) : _key = (pos1 << 14) | (score1 << 9) | (pos2 << 5) | score2;

  int get pos1 => _key >> 14;
  int get score1 => (_key >> 9) & 31;
  int get pos2 => (_key >> 5) & 15;
  int get score2 => _key & 31;

  @override
  String toString() => "player 1 at space ${pos1+1} with score $score1, player 2 at space ${pos2+1} with score $score2";

  @override
  bool operator ==(Object other) {
    if(other is! CountKey) {
      return false;
    }
    return _key == other._key;
  }

  @override
  int get hashCode => _key;

  bool get isWin1 => score1 >= winScore;
  bool get isWin2 => score2 >= winScore;
  bool get finished => isWin1 || isWin2;

  CountKey withThrow3(bool player1, Throw3Count t3) {
    if (player1) {
      final newPos = (pos1 + t3.sum) % trackLen;
      final newScore = score1 + newPos + 1;
      return CountKey(newPos, pos2, newScore, score2);
    }
    final newPos = (pos2 + t3.sum) % trackLen;
    final newScore = score2 + newPos + 1;
    return CountKey(pos1, newPos, score1, newScore);
  }
}
