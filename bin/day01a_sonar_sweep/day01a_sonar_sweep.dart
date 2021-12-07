import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('input.txt');
  Stream<String> lines =
      file.openRead().transform(utf8.decoder).transform(LineSplitter());
  try {
    int previousDepth = 0;
    var firstLine = true;
    int increases = 0;
    await for (final line in lines) {
      int depth = int.parse(line);
      if (firstLine) {
        firstLine = false;
      } else {
        if (depth > previousDepth) {
          increases++;
        }
      }
      previousDepth = depth;
    }
    stdout.writeln(increases);
  } catch (e) {
    stderr.addError(e);
  }
}
