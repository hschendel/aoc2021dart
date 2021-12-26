import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final parser = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<Parser>(Parser(), (p, line) => p.parseLine(line));
    final game = DiracDiceGame(parser.startPos);
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

class DiracDiceGame {
  final pos = <int>[];
  final score = List.filled(2, 0);
  final _die = DeterministicDie();

  static const trackLen = 10;
  static const winScore = 1000;

  DiracDiceGame(Iterable<int> startPos) {
    pos.addAll(startPos);
  }

  bool _turn(int player) {
    final dieScore = _die.roll3();
    pos[player] = (pos[player] + dieScore) % trackLen;
    score[player] += pos[player] + 1;
    return score[player] >= winScore;
  }

  int run() {
    for(var player = 0, win = false; !win; player = (player + 1) % pos.length) {
      win = _turn(player);
    }
    final loserScore = lowestScore();
    return loserScore * _die.rolls;
  }

  int lowestScore() {
    var low = score[0];
    for(final playerScore in score) {
      if (playerScore < low) {
        low = playerScore;
      }
    }
    return low;
  }
}

class DeterministicDie {
  var rolls = 0;
  static const faces = 100;

  int roll3() {
    final score = (rolls % faces) + ((rolls + 1) % faces) + ((rolls + 2) % faces) + 3;
    rolls += 3;
    return score;
  }
}