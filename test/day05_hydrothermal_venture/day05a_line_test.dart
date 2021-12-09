import 'dart:math';

import 'package:test/test.dart';
import '../../bin/day05_hydrothermal_venture/day05a_hydrothermal_venture.dart';

void main() {
  test("parse 1,2 -> 30,41", () {
    final line = Line.parse("1,2 -> 30,41");
    expect(line.a, equals(Point(1,2)));
    expect(line.b, equals(Point(30,41)));
  });
  test("toString 1,2 -> 30,41", () {
    final line = Line(Point(1,2), Point(30,41));
    final s = line.toString();
    expect(s, equals("1,2 -> 30,41"));
  });

  final intersectTestCases = <_LineTestCase>[
    _LineTestCase(
        Line(Point(1,1), Point(1,1)),
        Line(Point(1,1), Point(1,1)),
        [Point(1,1)]
    ),
    _LineTestCase(
        Line(Point(1,1), Point(1,1)),
        Line(Point(1,2), Point(1,2)),
        []
    ),
    _LineTestCase(
        Line(Point(0,5), Point(0,10)),
        Line(Point(0,8), Point(0,30)),
        [Point(0,8), Point(0,9), Point(0,10)]
    ),
    _LineTestCase(
        Line(Point(1,3), Point(10,3)),
        Line(Point(10,3), Point(30,3)),
        [Point(10,3)]
    ),
    _LineTestCase(
        Line(Point(1,3), Point(10,3)),
        Line(Point(11,3), Point(30,3)),
        []
    ),
    _LineTestCase(
        Line(Point(3,1), Point(3,5)),
        Line(Point(1,3), Point(5,3)),
        [Point(3,3)]
    ),
    _LineTestCase(
        Line(Point(100,100), Point(1000,100)),
        Line(Point(200,0), Point(200,1000)),
        [Point(200,100)]
    ),
  ];

  for(final testCase in intersectTestCases) {
    test(testCase.toString(), () {
      final gotIntersectionPoints = testCase.line1.intersect(testCase.line2);
      expect(gotIntersectionPoints, unorderedEquals(testCase.expectedIntersectionPoints));
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
    final pointsStr = expectedIntersectionPoints.map((p) => "${p.x},${p.y}").join(" ");
    return "intersect $line1 | $line2 = [$pointsStr]";
  }
}