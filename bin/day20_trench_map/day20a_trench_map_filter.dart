import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final proc = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<Processor>(Processor(), (p, line) => p.parseLine(line));
    final pass1 = proc.map.applyFilter(proc.filter);
    stdout.writeln("Pass 1 (${pass1.width}x${pass1.height})");
    stdout.writeln(pass1);
    final pass2 = pass1.applyFilter(proc.filter);
    stdout.writeln("Pass 2 (${pass2.width}x${pass2.height})");
    stdout.writeln(pass2);
    stdout.writeln(pass2.lightPixelCount);
  } catch (e) {
    stderr.addError(e);
  }
}

class Processor {
  var _parseMode = 0;
  final map = TrenchMap();
  Filter? _filter;

  Filter get filter => _filter!;

  Processor parseLine(String s) {
    switch (_parseMode) {
      case 0:
        _filter = Filter.fromString(s);
        _parseMode = 1;
        return this;
      case 1:
        if (s.isNotEmpty) {
          throw ArgumentError.value(s, "s", "expected empty second line");
        }
        _parseMode = 2;
        return this;
      default:
        map.parseLine(s);
        return this;
    }
  }
}

class TrenchMap {
  final _lightPixels = <Point<int>>{};
  var _minX = 0;
  var _maxX = 0;
  var _minY = 0;
  var _maxY = 0;
  var _addLineY = 0;
  var _defaultLight = false;

  TrenchMap();

  TrenchMap._fromLightPixels(Iterable<Point<int>> lightPixels, bool defaultLight) : _defaultLight = defaultLight {
    lightPixels.forEach(_setLight);
  }

  TrenchMap parseLine(String s) {
    _maxX = max(_maxX, s.length-1);
    _maxY = max(_maxY, _addLineY);
    for(var x=0; x < s.length; x++) {
      if (s[x] == "#") {
        _lightPixels.add(Point(x, _addLineY));
      }
    }
    _addLineY++;
    return this;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for(var y=_minY; y <= _maxY; y++) {
      for(var x=_minX; x <= _maxX; x++) {
        if (_lightPixels.contains(Point(x,y))) {
          sb.write("#");
        } else {
          sb.write(".");
        }
      }
      sb.writeln();
    }
    return sb.toString();
  }

  int get lightPixelCount => _lightPixels.length;

  bool _inKnown(int x, int y) => _minX <= x && x <= _maxX && _minY <= y && y <= _maxY;

  bool at(int x, int y) {
    if (_inKnown(x, y)) {
      return _lightPixels.contains(Point(x,y));
    }
    return _defaultLight;
  }

  void _setLight(Point<int> p) {
    _lightPixels.add(p);
    _minX = min(_minX, p.x);
    _maxX = max(_maxX, p.x);
    _minY = min(_minY, p.y);
    _maxY = max(_maxY, p.y);
  }

  int get width => (_maxX - _minX) + 1;
  int get height => (_maxY - _minY) + 1;

  List<bool> windowAt(int centerX, int centerY, int radius) {
    final pixels = <bool>[];
    for(var y = centerY - radius; y <= (centerY + radius); y++) {
      for (var x = centerX - radius; x <= (centerX + radius); x++) {
        pixels.add(at(x,y));
      }
    }
    return pixels;
  }

  TrenchMap applyFilter(Filter f) {
    final newLightPixels = <Point<int>>{};
    final startX = _minX - f.radius;
    final endX = _maxX + f.radius;
    final startY = _minY - f.radius;
    final endY = _maxY + f.radius;

    for(var y = startY; y <= endY; y++) {
      for(var x = startX; x <= endX; x++) {
        final pixels = windowAt(x, y, f.radius);
        final newValue = f.apply(pixels);
        if (newValue) {
          newLightPixels.add(Point(x,y));
        }
      }
    }

    final newDefaultLight = _defaultLight ? f.allLight : f.allDark;
    return TrenchMap._fromLightPixels(newLightPixels, newDefaultLight);
  }
}

class Filter {
  final _lightOutputs = <int>{};

  Filter.fromString(String s) {
    if (s.length != 512) {
      throw ArgumentError.value(s, "s", "must have exactly 512 characters");
    }
    for(var i=0; i<s.length; i++) {
      switch(s[i]) {
        case ".": break;
        case "#": _lightOutputs.add(i); break;
        default: throw ArgumentError.value(s, "s", "invalid character '${s[i]}' at position ${i+1}");
      }
    }
  }

  bool apply(List<bool> pixels) {
    if (pixels.length != 9) {
      throw ArgumentError.value(pixels, "pixels", "length != 9");
    }
    var key = 0;
    for (final pixel in pixels) {
      key = (key << 1) | (pixel ? 1 : 0);
    }
    return _lightOutputs.contains(key);
  }

  int get radius => 1;
  bool get allDark => _lightOutputs.contains(0);
  bool get allLight => _lightOutputs.contains(511);
}