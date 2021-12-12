import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final caveSys = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<CaveSystem>(CaveSystem(), (sys, line) => sys.addEdge(line));
    final pathCount = caveSys.countPaths();
    stdout.writeln(pathCount);
  } catch (e) {
    stderr.addError(e);
  }
}

class CaveSystem {
  final edges = <String,Set<String>>{};

  static final _edgeRegExp = RegExp(r"^([^\s\-]+)\-([^\s\-]+)$");

  CaveSystem addEdge(String s) {
    final match = _edgeRegExp.firstMatch(s);
    if (match == null) {
      throw ArgumentError.value(s, "s", "invalid edge expression");
    }
    String a = match.group(1)!;
    String b = match.group(2)!;
    if (isBigCave(a) && isBigCave(b)) {
      // if two big caves were connected directly, we would have cycles
      throw ArgumentError.value(s, "s", "invalid edge expression: must not connect two big caves");
    }
    var aEdges = edges[a] ?? <String>{};
    aEdges.add(b);
    edges[a] = aEdges;
    var bEdges = edges[b] ?? <String>{};
    bEdges.add(a);
    edges[b] = bEdges;
    return this;
  }

  int countPaths() {
    return _countPaths("start", {}, false);
  }

  int _countPaths(String from, Set<String> visited, bool smallCaveTwiceUsed) {
    final outEdges = edges[from];
    if (outEdges == null) {
      return 0;
    }
    if (from == "end") {
      return 1;
    }
    var removeFromVisited = true;
    if (!isBigCave(from) && visited.contains(from)) {
      if (smallCaveTwiceUsed || from == "start") {
        return 0;
      }
      smallCaveTwiceUsed = true;
      removeFromVisited = false;
    } else {
      visited.add(from);
    }
    var count = 0;
    for (final to in outEdges) {
      count += _countPaths(to, visited, smallCaveTwiceUsed);
    }
    if (removeFromVisited) {
      visited.remove(from); // leave visited as before
    }
    return count;
  }

  bool connected(String a, String b) => edges.containsKey(a) && edges[a]!.contains(b);

  static bool isBigCave(String c) {
    return c.isNotEmpty && c[0].toUpperCase() == c[0];
  }
}