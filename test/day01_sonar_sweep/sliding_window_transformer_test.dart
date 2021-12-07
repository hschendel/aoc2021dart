import 'dart:convert';
import 'package:test/test.dart';
import '../../bin/day01_sonar_sweep/day01b_sonar_sweep_sliding.dart';

void main() {
  final cases = <List<List<int>>>[
    [[], []],
    [
      [1],
      []
    ],
    [
      [1, 2],
      []
    ],
    [
      [1, 10, 100],
      [111]
    ],
    [
      [1, 10, 100, 1000],
      [111, 1110]
    ],
    [
      [199, 200, 208, 210, 200, 207, 240, 269, 260, 263],
      [607, 618, 618, 617, 647, 716, 769, 792]
    ]
  ];
  final transformer = makeSlidingWindowTransformer(3);
  for (final testCase in cases) {
    test("window size 3, ${jsonEncode(testCase[0])}", () {
      final winSumStream =
          Stream.fromIterable(testCase[0]).transform(transformer);
      expect(winSumStream, emitsInOrder([...testCase[1], emitsDone]));
    });
  }
}
