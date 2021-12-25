import 'dart:math';

import 'package:test/test.dart';
import '../../bin/day19_beacon_scanner/day19a_beacon_scanner_match.dart';

void main() {
  testTryMerge();
}

void testTryMerge() {
  final cases = <SetTestCase>[
    SetTestCase({Point3(1,20,300)}, {Point3(0,0,0)}, {Point3(1,20,300)})
  ];
  for(final c in cases) {
    test(c.label("tryMerge"), () {
      final m = Report.tryMerge(c.i1, c.i2, threshold: min(c.i2.length, 12));
      expect(m, equals(c.e));
    });
  }
}

class SetTestCase {
  final Set<Point3> i1;
  final Set<Point3> i2;
  final Set<Point3>? e;

  SetTestCase(this.i1, this.i2, this.e);

  String label(String operation) => "$operation on $i1 and $i2 must yield $e";
}