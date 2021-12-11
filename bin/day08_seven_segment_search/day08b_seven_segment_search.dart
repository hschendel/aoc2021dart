import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  final lookup = buildLookup(); // dynamic programming
  try {
    var sum = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => DisplayEntry.fromString(line))
        .map((entry) => entry.solve(lookup))
        .fold<int>(0, (sum, output) => sum + output);
    stdout.writeln(sum);
  } catch (e) {
    stderr.addError(e);
  }
}

final _codeA = "a".runes.first;

class DisplayEntry {
  final List<int> patterns = List.filled(10, 0);
  final List<int> output = List.filled(4, 0);

  DisplayEntry.fromString(String s) {
    final entries = s.split(" ");
    if (entries.length != 15 || entries[10] != "|") {
      throw FormatException("invalid format", s);
    }
    for (var i = 0; i < 10; i++) {
      patterns[i] = parseDigit(entries[i]);
    }
    for (var i = 0; i < 4; i++) {
      output[i] = parseDigit(entries[i + 11]);
    }
  }
  
  String get _lookupKey => buildLookupKey(patterns);
  
  int solve(Map<String, List<int>> lookup) {
    final m = lookup[_lookupKey]!;
    var value = 0;
    var factor = 1;
    for(var i=3; i >= 0; i--) {
      final translated = translate(m, output[i]);
      final number = digitsToNumber[translated];
      if (number == null) {
        throw UnsupportedError("no number found for ${digitToString(output[i])} translated to ${digitToString(translated)}, lookup key $_lookupKey");
      }
      value += factor * number;
      factor *= 10;
    }
    return value;
  }
}

int parseDigit(String pattern) {
  var bits = 0;
  for(final c in pattern.runes) {
    final i = c - _codeA;
    if (i < 0 || i >= 7) {
      throw FormatException("invalid character '${String.fromCharCode(c)}'", pattern);
    }
    bits |= 1 << i;
  }
  return bits;
}

String digitToString(int digit) {
  final sb = StringBuffer();
  for (var i=0; i < 7; i++) {
    if ((digit & (1 << i)) != 0) {
      sb.writeCharCode(_codeA + i);
    }
  }
  return sb.toString();
}

final correctDigits = <int>[
  parseDigit("abcefg"),
  parseDigit("cf"),
  parseDigit("acdeg"),
  parseDigit("acdfg"),
  parseDigit("bcdf"),
  parseDigit("abdfg"),
  parseDigit("abdefg"),
  parseDigit("acf"),
  parseDigit("abcdefg"),
  parseDigit("abcdfg")
];

final digitsToNumber = correctDigits.asMap().map((number, digit) => MapEntry(digit, number));

Iterable<List<int>> permutations() => _generatePermutations(<int>[], <int>{0,1,2,3,4,5,6});

Iterable<List<int>> _generatePermutations(List<int> m, Set<int> freeBits) sync* {
  if (freeBits.isEmpty) {
    yield List.from(m);
    return;
  }
  for(final i in freeBits.toList()) {
    m.add(i);
    freeBits.remove(i);
    yield* _generatePermutations(m, freeBits);
    freeBits.add(i);
    m.removeLast();
  }
}

int translate(List<int> m, int digit) {
  var translated = 0;
  for(var i=0; i < 7; i++) {
    if ((digit & 1 << i) != 0) {
      final translatedBit = 1 << m[i];
      translated |= translatedBit;
    }
  }
  return translated;
}

List<int> reverseMap(List<int> m) {
  final r = List.filled(7, 0);
  for(var i=0; i < 7; i++) {
    r[m[i]] = i;
  }
  return r;
}

String buildLookupKey(Iterable<int> patterns) {
  final stringList = patterns.map(digitToString).toList();
  stringList.sort();
  return stringList.join(" ");
}

Map<String, List<int>> buildLookup() {
  final lookup = <String, List<int>>{};
  for(final m in permutations()) {
    final r = reverseMap(m);
    final key = buildLookupKey(correctDigits.map((digit) => translate(r, digit)));
    lookup[key] = m;
  }
  return lookup;
}