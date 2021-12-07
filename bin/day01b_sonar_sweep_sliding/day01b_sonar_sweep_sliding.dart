import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final file = File('input.txt');
  try {
    final increases = (await file
            .openRead()
            .transform(utf8.decoder)
            .transform(LineSplitter())
            .map<int>((line) => int.parse(line))
            .transform(makeSlidingWindowTransformer(3))
            .fold<_IncreaseCounter>(
                _IncreaseCounter(), (counter, value) => counter.process(value)))
        .increases;
    stdout.writeln(increases);
  } catch (e) {
    stderr.addError(e);
  }
}

StreamTransformer<int, int> makeSlidingWindowTransformer(int windowLength) {
  final windowSums = List<int?>.filled(windowLength, null);
  var nextWindow = 0;
  void emit(EventSink<int> sink) {
    if (windowSums[nextWindow] != null) {
      sink.add(windowSums[nextWindow]!);
    }
  }

  void reset() {
    windowSums.fillRange(0, windowSums.length, null);
    nextWindow = 0;
  }

  return StreamTransformer.fromHandlers(
      handleData: (int data, EventSink<int> sink) {
    emit(sink);
    windowSums[nextWindow] = data;
    for (var i = 1; i < windowSums.length; i++) {
      var window = nextWindow - i;
      if (window < 0) {
        window = windowSums.length + window;
      }
      if (windowSums[window] != null) {
        windowSums[window] = windowSums[window]! + data;
      }
    }
    nextWindow = (nextWindow + 1) % windowSums.length;
  }, handleDone: (EventSink<int> sink) {
    emit(sink);
    sink.close();
    // reset, so next stream is processed correctly
    reset();
  });
}

class _IncreaseCounter {
  bool _isFirst = true;
  int _lastValue = 0;
  int _increases = 0;

  int get increases => _increases;

  _IncreaseCounter process(int value) {
    if (_isFirst) {
      _isFirst = false;
    } else {
      if (value > _lastValue) {
        _increases++;
      }
    }
    _lastValue = value;
    return this;
  }
}
