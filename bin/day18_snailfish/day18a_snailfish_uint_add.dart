
import 'dart:convert';
import 'dart:io';

import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final inputs = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map(SnailfishUint.parse)
        .toList();
    final sum = inputs.skip(1).fold<SnailfishUint>(inputs.first, (a, b) => a.add(b));
    stdout.writeln(sum.magnitude());
  } catch (e) {
    stderr.addError(e);
  }
}

class SnailfishUint {
  late final int? value;
  late final SnailfishUint? left;
  late final SnailfishUint? right;

  static SnailfishUint parse(String s) {
    final parser = SnailfishUnitParser(s);
    return parser.parse();
  }

  SnailfishUint.value(int v) : value = v, left = null, right = null;
  SnailfishUint.pair(SnailfishUint left, SnailfishUint right) : left = left, right = right, value = null;

  SnailfishUint add(SnailfishUint other) {
    final sum = SnailfishUint.pair(this, other);
    final reducedSum = sum.reduce();
    return reducedSum;
  }

  bool get isPair => value == null;

  SnailfishUint reduce() {
    var x = this;
    var changed = true;
    while(changed) {
      changed = false;
      if (x.needsExploding()) {
        x = x.explode();
        changed = true;
        continue;
      }
      if (x.needsSplit()) {
        x = x.split();
        changed = true;
      }
    }
    return x;
  }

  bool needsExploding() => _needsExplodingRec(0);

  bool _needsExplodingRec(int depth) {
    if (depth == 4) {
      return isPair;
    }
    if (depth > 4) {
      return true;
    }
    if (!isPair) {
      return false;
    }
    return left!._needsExplodingRec(depth+1) || right!._needsExplodingRec(depth+1);
  }

  SnailfishUint explode() {
    final exploded = _explodeRec(0);
    return exploded.item1;
  }

  Tuple3<SnailfishUint, int, int> _explodeRec(int depth) {
    if (!isPair) {
      return Tuple3(this, 0, 0);
    }
    if (depth >= 4) {
      return Tuple3(SnailfishUint.value(0), left!.value!, right!.value!);
    }
    // precedence for left side
    if (left!._needsExplodingRec(depth+1)) {
      final leftExploded = left!._explodeRec(depth+1);
      final newRight = right!._addToLeftMost(leftExploded.item3);
      return Tuple3(
        SnailfishUint.pair(leftExploded.item1, newRight),
        leftExploded.item2,
        0
      );
    }
    if (right!._needsExplodingRec(depth+1)) {
      final rightExploded = right!._explodeRec(depth+1);
      final newLeft = left!._addToRightMost(rightExploded.item2);
      return Tuple3(
        SnailfishUint.pair(newLeft, rightExploded.item1),
        0,
        rightExploded.item3
      );
    }
    return Tuple3(this, 0, 0);
  }

  SnailfishUint _addToLeftMost(int v) {
    if (v == 0) {
      return this;
    }
    if (!isPair) {
      return SnailfishUint.value(value! + v);
    }
    return SnailfishUint.pair(left!._addToLeftMost(v), right!);
  }

  SnailfishUint _addToRightMost(int v) {
    if (v == 0) {
      return this;
    }
    if (!isPair) {
      return SnailfishUint.value(value! + v);
    }
    return SnailfishUint.pair(left!, right!._addToRightMost(v));
  }

  bool needsSplit() {
    if (!isPair) {
      return value! >= 10;
    }
    return left!.needsSplit() || right!.needsSplit();
  }

  SnailfishUint split() {
    if (!isPair) {
      if (value! < 10) {
        return this;
      }
      final newLeft = value! ~/ 2;
      final newRight = value! - newLeft;
      return SnailfishUint.pair(SnailfishUint.value(newLeft), SnailfishUint.value(newRight));
    }
    // only the leftmost pair must split
    if (left!.needsSplit()) {
      final newLeft = left!.split();
      return SnailfishUint.pair(newLeft, right!);
    }
    if (right!.needsSplit()) {
      final newRight = right!.split();
      return SnailfishUint.pair(left!, newRight);
    }
    return this;
  }

  int magnitude() {
    if (!isPair) {
      return value!;
    }
    return 3 * left!.magnitude() + 2 * right!.magnitude();
  }

  @override
  String toString() {
    if (!isPair) {
      return "$value";
    }
    return "[${left.toString()},${right.toString()}]";
  }
}

class SnailfishUnitParser {
  final String s;
  int pos = 0;

  SnailfishUnitParser(this.s);

  SnailfishUint parse() {
    if (pos >= s.length) {
      throw ArgumentError.value(s, "s", "$pos: premature end of input");
    }
    String first = s[pos];
    pos++;
    if (first != "[") {
      if(!_isDigit(first)) {
        throw ArgumentError.value(s, "s", "${pos-1}: expected 0..9");
      }
      String literal = first;
      while (pos < s.length && _isDigit(s[pos])) {
        literal += s[pos];
        pos++;
      }
      return SnailfishUint.value(int.parse(literal));
    }
    final left = parse();
    if (pos >= s.length || s[pos] != ",") {
      throw ArgumentError.value(s, "s", "$pos: expected ,");
    }
    pos++;
    final right = parse();
    if (pos >= s.length || s[pos] != "]") {
      throw ArgumentError.value(s, "s", "$pos: expected ]");
    }
    pos++;
    return SnailfishUint.pair(left, right);
  }

  static final _isDigitRegExp = RegExp(r"^\d$");
  static bool _isDigit(String s) => _isDigitRegExp.hasMatch(s);
}