import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('input.txt');
  try {
    final counter = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => _parseBinary(line))
        .fold<_BitCounter>(
            _BitCounter(), (counter, word) => counter.count(word));
    final gammaRate = _binaryToInt(counter.mostCommonBits);
    final epsilonRate = _binaryToInt(counter.leastCommonBits);
    final powerConsumption = gammaRate * epsilonRate;
    stdout.writeln(powerConsumption);
  } catch (e) {
    stderr.addError(e);
  }
}

List<bool> _parseBinary(String s) {
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

class _BitCounter {
  final List<int> _trueCounts = [];
  int _valuesCounted = 0;
  int _wordWidth = 0;

  _BitCounter();

  _BitCounter count(List<bool> word) {
    if (word.length > _wordWidth) {
      _wordWidth = word.length;
    }
    _valuesCounted++;
    for (int i = 0; i < word.length; i++) {
      if (word[i]) {
        _increaseTrueCountAt(i);
      }
    }
    return this;
  }

  int get wordWidth => _wordWidth;

  _increaseTrueCountAt(int bit) {
    while (bit >= _trueCounts.length) {
      _trueCounts.add(0);
    }
    _trueCounts[bit]++;
  }

  int trueCountsAt(int bit) {
    if (bit >= _trueCounts.length) {
      return 0;
    }
    return _trueCounts[bit];
  }

  int falseCountsAt(int bit) {
    return _valuesCounted - _trueCounts[bit];
  }

  bool mostCommonAt(int bit) {
    return trueCountsAt(bit) >= falseCountsAt(bit);
  }

  bool leastCommonAt(int bit) {
    return !mostCommonAt(bit);
  }

  List<bool> get mostCommonBits {
    final l = <bool>[];
    for (var i = 0; i < wordWidth; i++) {
      l.add(mostCommonAt(i));
    }
    return l;
  }

  List<bool> get leastCommonBits {
    final l = <bool>[];
    for (var i = 0; i < _wordWidth; i++) {
      l.add(leastCommonAt(i));
    }
    return l;
  }
}
