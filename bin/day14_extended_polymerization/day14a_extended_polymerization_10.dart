import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final process = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<PolymerizationProcess>(PolymerizationProcess(), (p, line) => p.parseLine(line));
    process.steps(10);
    var minCount = 0;
    var maxCount = 0;
    process.elementCounts.forEach((_, count) {
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
    stdout.writeln(maxCount - minCount);
  } catch (e) {
    stderr.addError(e);
  }
}

class PolymerizationProcess {
  String _polymer = "";
  final _rules = <String, String>{};
  bool _expectEmptyLine = true;

  static final _ruleRegExp = RegExp(r"^([A-Z]{2}) -> ([A-Z])$");

  PolymerizationProcess parseLine(String s) {
    if (_polymer.isEmpty) {
      if (s.isEmpty) {
        throw ArgumentError.value(s, "s", "expected template");
      }
      _polymer = s;
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

  void step() {
    final insertions = List.filled(_polymer.length, "");
    for(var i=0; i < _polymer.length-1; i++) {
      final pair = _polymer.substring(i,i+2);
      insertions[i+1] = _rules[pair] ?? "";
    }
    final sb = StringBuffer();
    for(var i=0; i < _polymer.length; i++) {
      sb.write(insertions[i]);
      sb.write(_polymer[i]);
    }
    _polymer = sb.toString();
  }

  void steps(int n) {
    for(var i=0; i < n; i++) {
      step();
    }
  }

  Map<String, int> get elementCounts {
    final m = <String, int>{};
    for(var i=0; i < _polymer.length; i++) {
      var count = m[_polymer[i]] ?? 0;
      count++;
      m[_polymer[i]] = count;
    }
    return m;
  }
}
