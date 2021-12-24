import 'package:test/test.dart';
import '../../bin/day18_snailfish/day18a_snailfish_uint_add.dart';

void main() {
  test("needsSplit", () {
    final i1 = SnailfishUint.parse("[[[[0,7],4],[15,[0,13]]],[1,1]]");
    expect(i1.needsSplit(), equals(true));
    final i2 = SnailfishUint.parse("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]");
    expect(i2.needsSplit(), equals(false));
  });
  test("split", () {
    final i1 = SnailfishUint.parse("[[[[0,7],4],[15,[0,13]]],[1,1]]");
    expect(i1.split().toString(), equals("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]"));
    final i2 = i1.split();
    expect(i2.split().toString(), equals("[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]"));
    final i3 = SnailfishUint.parse("11");
    expect(i3.split().toString(), equals("[5,6]"));
    final i4 = SnailfishUint.parse("10");
    expect(i4.split().toString(), equals("[5,5]"));
    final i5 = SnailfishUint.parse("13");
    expect(i5.split().toString(), equals("[6,7]"));
  });
  test("explode", () {
    final i1 = SnailfishUint.parse("[[[[[9,8],1],2],3],4]");
    final g1 = i1.explode();
    expect(g1.toString(), equals("[[[[0,9],2],3],4]"));

    final i2 = SnailfishUint.parse("[7,[6,[5,[4,[3,2]]]]]");
    final g2 = i2.explode();
    expect(g2.toString(), equals("[7,[6,[5,[7,0]]]]"));

    final i3 = SnailfishUint.parse("[[6,[5,[4,[3,2]]]],1]");
    final g3 = i3.explode();
    expect(g3.toString(), equals("[[6,[5,[7,0]]],3]"));

    final i4 = SnailfishUint.parse("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]");
    final g4 = i4.explode();
    expect(g4.toString(), equals("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"));

    final i5 = SnailfishUint.parse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]");
    final g5 = i5.explode();
    expect(g5.toString(), equals("[[3,[2,[8,0]]],[9,[5,[7,0]]]]"));
  });
  test("reduce", () {
    final i1 = SnailfishUint.parse("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]");
    final g1 = i1.reduce();
    expect(g1.toString(), equals("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"));
  });
  test("add", () {
    final i1a = SnailfishUint.parse("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]");
    final i1b = SnailfishUint.parse("[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]");
    final g1 = i1a.add(i1b);
    expect(g1.toString(), equals("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"));

    final i2a = SnailfishUint.parse("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]");
    final i2b = SnailfishUint.parse("[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]");
    final g2 = i2a.add(i2b);
    expect(g2.toString(), equals("[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]"));
  });
}