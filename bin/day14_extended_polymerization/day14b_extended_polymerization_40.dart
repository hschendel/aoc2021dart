import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final process = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<PolymerizationProcess>(PolymerizationProcess(), (p, line) => p.parseLine(line));
    var elemCounts = process.elementCountAfterSteps(40);
    stdout.writeln(minMaxDiff(elemCounts));
    //process.dumpCounts();
  } catch (e) {
    stderr.addError(e);
  }
}

int minMaxDiff(Map<String, int> elemCounts) {
  var minCount = 0;
  var maxCount = 0;
  elemCounts.forEach((_, count) {
    if (minCount == 0) {
      minCount = count;
      maxCount = count;
      return;
    }
    if (count < minCount) {
      minCount = count;
    } else if (count > maxCount) {
      maxCount = count;
    }
  });
  return maxCount - minCount;
}

class PolymerizationProcess {
  String _initialPolymer = "";
  final _rules = <String, String>{};
  bool _expectEmptyLine = true;

  static final _ruleRegExp = RegExp(r"^([A-Z]{2}) -> ([A-Z])$");

  String get initialPolymer => _initialPolymer;

  PolymerizationProcess parseLine(String s) {
    if (_initialPolymer.isEmpty) {
      if (s.isEmpty) {
        throw ArgumentError.value(s, "s", "expected template");
      }
      _initialPolymer = s;
      return this;
    } else if(_expectEmptyLine) {
      if (s.isNotEmpty) {
        throw ArgumentError.value(s, "s", "expected empty line before rules");
      }
      _expectEmptyLine = false;
      return this;
    }
    final match = _ruleRegExp.firstMatch(s);
    if (match == null) {
      throw ArgumentError.value(s, "s", "expected insertion rule, e.g. 'AB -> C'");
    }
    _rules[match.group(1)!] = match.group(2)!;
    return this;
  }

  Map<String, int> elementCountAfterSteps(int n) {
    // elemCount is the result data structure
    // As elements are only inserted into the polymer, every insertion
    // causes one element count to be incremented.
    final elemCount = <String,int>{};
    // Initialize with initial polymer
    for(var i=0; i < _initialPolymer.length; i++) {
      final ch = _initialPolymer[i];
      elemCount[ch] = (elemCount[ch] ?? 0) + 1;
    }

    // pairCount is used to reduce the space and time complexity, to
    // get the counts of the elements generated in a step, it is sufficient
    // to know the pairs occuring in the current polymer, and the count of
    // their repetitions. Pairs are stored as strings of length 2.
    var pairCount = <String,int>{};
    // Initialize with pairs from initial polymer.
    for (var i=0; i < _initialPolymer.length-1; i++) {
      final pair = _initialPolymer[i] + _initialPolymer[i + 1];
      pairCount[pair] = (pairCount[pair] ?? 0) + 1;
    }

    // Run through the steps
    for (var step=0; step < n; step++) {
      final newPairCount = <String,int>{};
      for (final entry in pairCount.entries) {
        final newCh = _rules[entry.key]!;
        // Through the pair entry.key, newCh is inserted entry.value times
        // into the polymer in this step.
        elemCount[newCh] = (elemCount[newCh] ?? 0) + entry.value;
        // through the insertion, we have two new pairs, replacing the old one
        // (always entry.value times repeated)
        final newPair1 = entry.key[0] + newCh;
        final newPair2 = newCh + entry.key[1];
        newPairCount[newPair1] = (newPairCount[newPair1] ?? 0) + entry.value;
        newPairCount[newPair2] = (newPairCount[newPair2] ?? 0) + entry.value;
      }
      pairCount = newPairCount;
    }
    return elemCount;
  }
}
