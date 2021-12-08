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
  final splitFalseStrings = <String>[
    "00100",
    "01111",
    "00111",
    "00010",
    "01010"
  ];
  final splitTrueStrings = <String>[
    "11110",
    "10110",
    "10111",
    "10101",
    "11100",
    "10000",
    "11001"
  ];
  final input = inputStrings.map((s) => parseBinary(s)).toList();
  final expectedTrue = splitTrueStrings.map((s) => parseBinary(s)).toList();
  final expectedFalse = splitFalseStrings.map((s) => parseBinary(s)).toList();

  test("splitByBit 0", () {
    final splitted = splitByBit(input, 0);
    expect(splitted.item1, expectedFalse);
    expect(splitted.item2, expectedTrue);
  });
}
