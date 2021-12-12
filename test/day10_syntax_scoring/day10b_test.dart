import 'package:test/test.dart';
import '../../bin/day10_syntax_scoring/day10b_syntax_scoring_incomplete.dart';

void main() {
  test("scoreStack for <{([ must be 294", () {
    expect(scoreStack(<String>["<","{","(","["]), equals(294));
  });
}