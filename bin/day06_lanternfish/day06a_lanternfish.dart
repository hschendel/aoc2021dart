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
    final fishesAfter80Days = lanternFishDays(initialFishes, 80);
    stdout.writeln(fishesAfter80Days.length);
  } catch (e) {
    stderr.addError(e);
  }
}

List<int> lanternFishDays(List<int> initialFishes, int days) {
  var fishes = initialFishes;
  for (var i = 0; i < days; i++) {
    fishes = lanternFishDay(fishes);
  }
  return fishes;
}

List<int> lanternFishDay(List<int> fishes) {
  final fishes2 = <int>[];
  var newFishes = 0;
  for (final fish in fishes) {
    if (fish == 0) {
      fishes2.add(6);
      newFishes++;
    } else {
      fishes2.add(fish - 1);
    }
  }
  for (var i = 0; i < newFishes; i++) {
    fishes2.add(8);
  }
  return fishes2;
}
