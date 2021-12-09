import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    var count1478 = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => DisplayEntry.fromString(line))
        .fold<int>(0, (sum, entry) => sum + entry.count1478());
    stdout.writeln(count1478);
  } catch (e) {
    stderr.addError(e);
  }
}

class DisplayEntry {
  final List<DisplayDigit> patterns = List.filled(10, DisplayDigit());
  final List<DisplayDigit> output = List.filled(4, DisplayDigit());

  DisplayEntry.fromString(String s) {
    final entries = s.split(" ");
    if (entries.length != 15 || entries[10] != "|") {
      throw FormatException("invalid format", s);
    }
    for (var i=0; i < 10; i++) {
      patterns[i] = DisplayDigit.fromString(entries[i]);
    }
    for (var i=0; i < 4; i++) {
      output[i] = DisplayDigit.fromString(entries[i+11]);
    }
  }

  int count1478() {
    final digitMap = <DisplayDigit, int>{};
    for(final pattern in patterns) {
      switch (pattern.activeSegements) {
        case 2:
          digitMap[pattern] = 1;
          break;
        case 3:
          digitMap[pattern] = 7;
          break;
        case 4:
          digitMap[pattern] = 4;
          break;
        case 7:
          digitMap[pattern] = 8;
          break;
      }
    }
    var count = 0;
    for(final digit in output) {
      final decoded = digitMap[digit];
      switch (decoded) {
        case 1:
        case 4:
        case 7:
        case 8:
          count++;
      }
    }
    return count;
  }
}

class DisplayDigit {
  int segments = 0;

  static final _codeA = "a".runes.first;

  DisplayDigit();

  DisplayDigit.fromString(String s) {
    for(final c in s.runes) {
      final i = c - _codeA;
      if (i < 0 || i >= 7) {
        throw FormatException("invalid character '${String.fromCharCode(c)}'", s);
      }
      segments |= 1 << i;
    }
  }

  String toString() {
    final sb = StringBuffer();
    for (var i=0; i < 7; i++) {
      if ((segments & (1 << i)) != 0) {
        sb.writeCharCode(_codeA + i);
      }
    }
    return sb.toString();
  }

  int get activeSegements {
    var sum = 0;
    for (var i=0; i < 7; i++) {
      if ((segments & (1 << i)) != 0) {
        sum++;
      }
    }
    return sum;
  }

  @override
  int get hashCode => segments;

  @override
  bool operator ==(Object other) {
    if (other is! DisplayDigit) {
      return false;
    }
    return other.segments == segments;
  }
}