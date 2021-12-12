import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final score = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => scoreLine(line))
        .fold<int>(0, (sum, lineScore) => sum + lineScore);

    stdout.writeln(score);
  } catch (e) {
    stderr.addError(e);
  }
}

String checkLine(String line) {
  final stack = <String>[];
  for(int i=0; i < line.length; i++) {
    final ch = line[i];
    if (isOpening(ch)) {
      stack.add(ch);
    } else if(isClosing(ch)) {
      final leftCh = stack.removeLast();
      if (!match(leftCh, ch)) {
        return ch;
      }
    } else {
      return "invalid character $ch"; // invalid character
    }
  }
  if (stack.isEmpty) {
    return "";
  } else {
    return "incomplete";
  }
}

int scoreLine(String line) {
  final checkResult = checkLine(line);
  switch (checkResult) {
    case ")":
      return 3;
    case "]":
      return 57;
    case "}":
      return 1197;
    case ">":
      return 25137;
    case "incomplete":
      return 0; // ignored
    default:
      throw ArgumentError.value(line, "line", checkResult);
  }
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