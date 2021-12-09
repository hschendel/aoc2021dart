import 'dart:math';

import 'package:test/test.dart';
import '../../bin/day05_hydrothermal_venture/day05b_hydrothermal_venture_diagonal.dart';

void main() {
  test("parse 1,2 -> 30,41", () {
    final line = Line.parse("1,2 -> 30,41");
    expect(line.a, equals(Point(1, 2)));
    expect(line.b, equals(Point(30, 41)));
  });
  test("toString 1,2 -> 30,41", () {
    final line = Line(Point(1, 2), Point(30, 41));
    final s = line.toString();
    expect(s, equals("1,2 -> 30,41"));
  });
  test("yAtX for 1,1 -> 3,3 at x=2 should be 2", () {
    final line = Line(Point(1, 1), Point(3, 3));
    final y = line.yAtX(2);
    expect(y, equals(2));
  });
  test("yAtX for 3,3 -> 1,1 at x=2 should be 2", () {
    final line = Line(Point(3, 3), Point(1, 1));
    final y = line.yAtX(2);
    expect(y, equals(2));
  });
  test("yAtX for 1,1 -> 3,3 at x=4 should be null", () {
    final line = Line(Point(1, 1), Point(3, 3));
    final y = line.yAtX(4);
    expect(y, equals(null));
  });
  test("yAtX for 1,1 -> 3,3 at x=3 should be 3", () {
    final line = Line(Point(1, 1), Point(3, 3));
    final y = line.yAtX(3);
    expect(y, equals(3));
  });
  test("yAtX for 1,3 -> 3,1 at x=2 should be 2", () {
    final line = Line(Point(1, 3), Point(3, 1));
    final y = line.yAtX(2);
    expect(y, equals(2));
  });
  test("yAtX for 1,3 -> 3,1 at x=1 should be 3", () {
    final line = Line(Point(1, 3), Point(3, 1));
    final y = line.yAtX(1);
    expect(y, equals(3));
  });
  test("yAtX for 1,3 -> 3,1 at x=0 should be null", () {
    final line = Line(Point(1, 3), Point(3, 1));
    final y = line.yAtX(0);
    expect(y, equals(null));
  });
  test("yAtX for 1,3 -> 3,1 at x=3 should be 1", () {
    final line = Line(Point(1, 3), Point(3, 1));
    final y = line.yAtX(3);
    expect(y, equals(1));
  });
  test("xAtY for 1,1 -> 3,3 at y=2 should be 2", () {
    final line = Line(Point(1, 1), Point(3, 3));
    final x = line.xAtY(2);
    expect(x, equals(2));
  });
  test("xAtY for 3,1 -> 3,10 at y=3 should be 3", () {
    final line = Line(Point(3, 1), Point(3, 10));
    final x = line.xAtY(3);
    expect(x, equals(3));
  });
  test("xAtY for 3,1 -> 3,10 at y=1 should be 3", () {
    final line = Line(Point(3, 1), Point(3, 10));
    final x = line.xAtY(1);
    expect(x, equals(3));
  });
  test("xAtY for 3,1 -> 3,10 at y=10 should be 3", () {
    final line = Line(Point(3, 1), Point(3, 10));
    final x = line.xAtY(10);
    expect(x, equals(3));
  });
  test("xAtY for 3,1 -> 3,10 at y=0 should be null", () {
    final line = Line(Point(3, 1), Point(3, 10));
    final x = line.xAtY(0);
    expect(x, equals(null));
  });
  final intersectTestCases = <_LineTestCase>[
    _LineTestCase(
        Line(Point(6, 4), Point(2, 0)), Line(Point(2, 2), Point(2, 1)), []),
    _LineTestCase(
        Line(Point(0, 0), Point(8, 8)), Line(Point(6, 4), Point(2, 0)), []),
    _LineTestCase(Line(Point(1, 1), Point(1, 1)),
        Line(Point(1, 1), Point(1, 1)), [Point(1, 1)]),
    _LineTestCase(
        Line(Point(1, 1), Point(1, 1)), Line(Point(1, 2), Point(1, 2)), []),
    _LineTestCase(
        Line(Point(0, 5), Point(0, 10)),
        Line(Point(0, 8), Point(0, 30)),
        [Point(0, 8), Point(0, 9), Point(0, 10)]),
    _LineTestCase(Line(Point(1, 3), Point(10, 3)),
        Line(Point(10, 3), Point(30, 3)), [Point(10, 3)]),
    _LineTestCase(
        Line(Point(1, 3), Point(10, 3)), Line(Point(11, 3), Point(30, 3)), []),
    _LineTestCase(Line(Point(3, 1), Point(3, 5)),
        Line(Point(1, 3), Point(5, 3)), [Point(3, 3)]),
    _LineTestCase(Line(Point(100, 100), Point(1000, 100)),
        Line(Point(200, 0), Point(200, 1000)), [Point(200, 100)]),
    _LineTestCase(Line(Point(1, 1), Point(3, 3)),
        Line(Point(1, 3), Point(3, 1)), [Point(2, 2)]),
    _LineTestCase(Line(Point(8, 0), Point(0, 8)),
        Line(Point(1, 4), Point(9, 4)), [Point(4, 4)]),
    _LineTestCase(
        Line(Point(0, 10), Point(10, 0)),
        Line(Point(1, 9), Point(3, 7)),
        [Point(1, 9), Point(2, 8), Point(3, 7)]),
    _LineTestCase(
        Line(Point(0, 10), Point(10, 0)), Line(Point(0, 11), Point(11, 0)), []),
    _LineTestCase(Line(Point(0, 10), Point(10, 0)),
        Line(Point(11, -1), Point(20, -10)), []),
    _LineTestCase(Line(Point(0, 10), Point(10, 0)),
        Line(Point(1, 1), Point(1, 10)), [Point(1, 9)]),
    _LineTestCase(Line(Point(0, 0), Point(10, 10)),
        Line(Point(1, 1), Point(1, 10)), [Point(1, 1)]),
  ];

  for (final testCase in intersectTestCases) {
    test(testCase.toString(), () {
      final gotIntersectionPoints = testCase.line1.intersect(testCase.line2);
      expect(gotIntersectionPoints,
          unorderedEquals(testCase.expectedIntersectionPoints));
    });
  }
}

class _LineTestCase {
  final Line line1;
  final Line line2;
  final List<Point<int>> expectedIntersectionPoints;

  _LineTestCase(this.line1, this.line2, this.expectedIntersectionPoints);

  @override
  String toString() {
    final pointsStr =
        expectedIntersectionPoints.map((p) => "${p.x},${p.y}").join(" ");
    return "intersect $line1 | $line2 = [$pointsStr]";
  }
}
