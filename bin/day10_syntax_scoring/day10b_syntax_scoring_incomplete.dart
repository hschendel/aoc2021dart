import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final scores = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => scoreLine(line))
        .where((score) => score != 0)
        .toList();
    scores.sort();
    final median = scores[scores.length ~/ 2];
    stdout.writeln(median);
  } catch (e) {
    stderr.addError(e);
  }
}

Tuple2<String, List<String>> checkLine(String line) {
  final stack = <String>[];
  for(int i=0; i < line.length; i++) {
    final ch = line[i];
    if (isOpening(ch)) {
      stack.add(ch);
    } else if(isClosing(ch)) {
      final leftCh = stack.removeLast();
      if (!match(leftCh, ch)) {
        return Tuple2("corrupted", []);
      }
    } else {
      return Tuple2("invalid character $ch", []); // invalid character
    }
  }
  return Tuple2("", stack);
}

int scoreLine(String line) {
  final t = checkLine(line);
  if (t.item1 == "corrupted" || t.item2.isEmpty) {
    return 0;
  }
  return scoreStack(t.item2);
}

int scoreStack(List<String> stack) {
  var score = 0;
  for (final ch in stack.reversed) {
    score *= 5;
    switch(ch) {
      case "(": score += 1; break;
      case "[": score += 2; break;
      case "{": score += 3; break;
      case "<": score += 4; break;
    }
  }
  return score;
}

bool isOpening(String ch) {
  switch(ch) {
    case "(":
    case "[":
    case "{":
    case "<":
      return true;
    default:
      return false;
  }
}

bool isClosing(String ch) {
  switch(ch) {
    case ")":
    case "]":
    case "}":
    case ">":
      return true;
    default:
      return false;
  }
}

bool match(String left, String right) {
  return left == "(" && right == ")"
      || left == "[" && right == "]"
      || left == "{" && right == "}"
      || left == "<" && right == ">";
}