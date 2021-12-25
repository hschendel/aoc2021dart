import 'package:test/test.dart';
import '../../bin/day19_beacon_scanner/day19a_beacon_scanner_match.dart';

void main() {
  testRotate();
}

void testRotate() {
  final base = Point3(1,20,300);
  final cases = <Point3Case>[
    Point3Case(0,1,1,20,-300,-1),
    Point3Case(0,0,0,1,20,300),
    Point3Case(0,0,1,20,-1,300),
    Point3Case(0,1,0,300,20,-1),
    Point3Case(1,0,0,1,300,-20),
    Point3Case(0,0,2,-1,-20,300),
  ];
  for(final c in cases) {
    test(c.label("rotate $base"), ()
      {
        final g = base.rotate(c.ir);
        expect(g, equals(c.e));
      }
    );
  }
}

class Point3Case {
  final int ix;
  final int iy;
  final int iz;
  final int ex;
  final int ey;
  final int ez;
  Point3Case(this.ix, this.iy, this.iz, this.ex, this.ey, this.ez);

  String label(String operation) {
    return "$operation with $ix,$iy,$iz must yield $ex,$ey,$ez";
  }

  Point3 get i => Point3(ix,iy,iz);
  Rotation3 get ir => Rotation3(ix,iy,iz);
  Point3 get e => Point3(ex,ey,ez);
}