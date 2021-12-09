import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    var firstLine = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .first;
    List<int> initialFishes = firstLine.split(",").map(int.parse).toList();
    final population = LanternFishPopulation.fromFishList(initialFishes);
    population.days(256);
    stdout.writeln(population.count);
  } catch (e) {
    stderr.addError(e);
  }
}

class LanternFishPopulation {
  final List<int> _counts = List.filled(9, 0, growable: true);

  LanternFishPopulation.fromFishList(List<int> fishes) {
    for (final fishState in fishes) {
      _counts[fishState]++;
    }
  }

  void day() {
    final spawning = _counts.removeAt(0);
    _counts[6] += spawning;
    _counts.add(spawning);
  }

  void days(int n) {
    for (var i = 0; i < n; i++) {
      day();
    }
  }

  int get count => _counts.fold(0, (sum, count) => sum + count);
}
