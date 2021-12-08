import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

void main() async {
  final file = File('input.txt');
  try {
    final input = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => parseBinary(line))
        .toList();
    final oxygenGeneratorRating = narrowMostCommonToOne(input);
    final co2ScrubberRating = narrowLeastCommonToOne(input);
    final answer =
        _binaryToInt(oxygenGeneratorRating) * _binaryToInt(co2ScrubberRating);
    stdout.writeln(answer);
  } catch (e) {
    stderr.addError(e);
  }
}

List<bool> parseBinary(String s) {
  final word = <bool>[];
  for (var i = 0; i < s.length; i++) {
    switch (s[i]) {
      case '0':
        word.add(false);
        break;
      case '1':
        word.add(true);
        break;
      default:
        throw FormatException("invalid character \"${s[i]}\"", s);
    }
  }
  return word;
}

int _binaryToInt(List<bool> word) {
  var bitValue = 1;
  var res = 0;
  for (var i = word.length - 1; i >= 0; i--) {
    if (word[i]) {
      res += bitValue;
    }
    bitValue *= 2;
  }
  return res;
}

List<bool> narrowMostCommonToOne(List<List<bool>> input) {
  int bit = 0;
  while (input.length > 1) {
    final splitted = splitByBit(input, bit);
    List<List<bool>> nextInput;
    if (splitted.item2.length >= splitted.item1.length) {
      nextInput = splitted.item2;
    } else {
      nextInput = splitted.item1;
    }
    if (nextInput.isEmpty) {
      return input[0]; // not really defined
    }
    input = nextInput;
    bit++;
  }
  if (input.isEmpty) {
    throw UnsupportedError("input is empty");
  }
  return input[0];
}

List<bool> narrowLeastCommonToOne(List<List<bool>> input) {
  int bit = 0;
  while (input.length > 1) {
    final splitted = splitByBit(input, bit);
    List<List<bool>> nextInput;
    if (splitted.item1.length <= splitted.item2.length) {
      nextInput = splitted.item1;
    } else {
      nextInput = splitted.item2;
    }
    if (nextInput.isEmpty) {
      return input[0]; // not really defined
    }
    if (input.isEmpty) {
      throw UnsupportedError("input is empty");
    }
    input = nextInput;
    bit++;
  }
  return input[0];
}

Tuple2<List<List<bool>>, List<List<bool>>> splitByBit(
    List<List<bool>> input, int bit) {
  final listFalse = <List<bool>>[];
  final listTrue = <List<bool>>[];
  for (final word in input) {
    if (word[bit]) {
      listTrue.add(word);
    } else {
      listFalse.add(word);
    }
  }
  return Tuple2(listFalse, listTrue);
}
