import 'package:test/test.dart';
import '../../bin/day03_binary_diagnostic/day03b_binary_diagnostic_life_support.dart';

void main() {
  final inputStrings = <String>[
    "00100",
    "11110",
    "10110",
    "10111",
    "10101",
    "01111",
    "00111",
    "11100",
    "10000",
    "11001",
    "00010",
    "01010"
  ];
  final input = inputStrings.map((s) => parseBinary(s)).toList();
  test("most common should be 10111", () {
    final narrowed = narrowMostCommonToOne(input);
    expect(narrowed, equals(parseBinary("10111")));
  });
  test("least common should be 01010", () {
    final narrowed = narrowLeastCommonToOne(input);
    expect(narrowed, equals(parseBinary("01010")));
  });
}