import 'dart:io';
import 'dart:convert';

import 'package:tuple/tuple.dart';

void main() async {
  final file = File('input.txt');
  try {
    final BingoFileParser parser = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .fold<BingoFileParser>(BingoFileParser(), (p, line) => p.parseLine(line));
    final result = playBoards(parser.numbers, parser.boards);
    stdout.writeln(result.firstWinningBoardScore);
  } catch (e) {
    stderr.addError(e);
  }
}

BingoGameResult playBoards(List<int> numbers, List<BingoBoard> boards) {
  final result = BingoGameResult();
  for(var boardIndex = 0; boardIndex < boards.length; boardIndex++) {
    final board = boards[boardIndex];
    final boardResult = board.play(numbers);
    result.addBoardResult(boardIndex, boardResult);
  }
  return result;
}

class BingoGameResult {
  int? _winningNumberIndex;
  final List<Tuple2<int, int>> _winningBoards = [];

  void addBoardResult(int boardIndex, BingoBoardResult boardResult) {
    if (!boardResult.complete) {
      return;
    }
    final entry = Tuple2<int, int>(boardIndex, boardResult.score!);
    if (_winningNumberIndex == null) {
      _winningNumberIndex = boardResult.winIndex;
      _winningBoards.add(entry);
      return;
    }
    if (_winningNumberIndex! < boardResult.winIndex!) {
      return;
    }
    if (_winningNumberIndex! > boardResult.winIndex!) {
      _winningBoards.clear();
    }
    _winningNumberIndex = boardResult.winIndex!;
    _winningBoards.add(entry);
  }

  List<Tuple2<int, int>> get winningBoardsWithScore => _winningBoards;

  bool get hasWinningBoard => _winningBoards.isNotEmpty;

  int get firstWinningBoardScore {
    return _winningBoards.fold(-1, (bestScore, entry) => entry.item2 > bestScore ? entry.item2 : bestScore);
  }
}

class BingoFileParser {
  final List<int> _numbers = [];
  final List<BingoBoard> _boards = [];
  bool _firstLine = true;
  int _boardLineIdx = -1;
  int _lineNo = 1;
  List<List<int>> _boardLines = [];

  List<int> get numbers => _numbers;
  List<BingoBoard> get boards => _boards;

  BingoFileParser parseLine(String line) {
    if (_firstLine) {
      _parseFirstLine(line);
      _firstLine = false;
      _lineNo++;
      return this;
    }
    if (_boardLineIdx == -1) {
      if (line.isNotEmpty) {
        throw FormatException("line $_lineNo: should be empty", line);
      }
      _lineNo++;
      _boardLineIdx++;
      return this;
    }
    _boardLines.add(_parseBoardLine(line));
    _lineNo++;
    _boardLineIdx++;

    if (_boardLineIdx == 5) {
      _boards.add(BingoBoard(_boardLines));
      _boardLines = []; // always new so the object can be used inside BingoBoard
      _boardLineIdx = -1;
    }

    return this;
  }

  void _parseFirstLine(String line) {
    try {
      _numbers.addAll(line.split(",").map(int.parse));
    } on FormatException catch (e) {
      throw FormatException("line $_lineNo: ${e.message}", line);
    }
  }

  static final _boardLineRegexp = RegExp(r"^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$");

  List<int> _parseBoardLine(String line) {
    final match = _boardLineRegexp.firstMatch(line);
    if (match == null) {
      throw FormatException("line $_lineNo: not 5 numbers", line);
    }
    List<int> values = [];
    try {
      for (var i=1; i <= 5; i++) {
        values.add(int.parse(match.group(i)!));
      }
    } on FormatException catch (e) {
      throw FormatException("line $_lineNo: ${e.message} (${e.source})", line);
    }
    return values;
  }
}

class BingoBoard {
  final _posToNumber = <Tuple2<int, int>, int>{};
  final _numberToPos = <int, Tuple2<int, int>>{};

  BingoBoard(List<List<int>> board) {
    for (var row=0; row < board.length; row++) {
      final rowData = board[row];
      for (var col=0; col < rowData.length; col++) {
        final pos = Tuple2<int, int>(row, col);
        _posToNumber[pos] = rowData[col];
        _numberToPos[rowData[col]] = pos;
      }
    }
  }

  BingoBoardResult play(List<int> numbers) {
    final state = _BingoBoardState();
    for(var i=0; i < numbers.length; i++) {
      final number = numbers[i];
      final pos = _numberToPos[number];
      if (pos == null) {
        continue;
      }
      final complete = state.mark(pos);
      if (complete) {
        final sumOfUnmarked = _sumOfPositions(state.unmarkedPositions);
        final score = sumOfUnmarked * number;
        return BingoBoardResult.complete(i, score);
      }
    }
    return BingoBoardResult.incomplete();
  }

  int _sumOfPositions(List<Tuple2<int, int>> positions) {
    int sum = 0;
    for(final pos in positions) {
      final number = _posToNumber[pos]!;
      sum += number;
    }
    return sum;
  }
}

class _BingoBoardState {
  final _marked = <Tuple2<int, int>>{};

  // Mark a position as completed, check whether the board now
  // has a complete row or column, and return true if so.
  bool mark(Tuple2<int, int> pos) {
    _marked.add(pos);
    return _rowComplete(pos.item1) || _columnComplete(pos.item2);
  }

  List<Tuple2<int, int>> get unmarkedPositions {
    final unmarked = <Tuple2<int, int>>[];
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 5; col++) {
        final pos = Tuple2<int, int>(row, col);
        if (!_marked.contains(pos)) {
          unmarked.add(pos);
        }
      }
    }
    return unmarked;
  }

  bool _rowComplete(int row) {
    for (var col = 0; col < 5; col++) {
      if (!_marked.contains(Tuple2<int, int>(row, col))) {
        return false;
      }
    }
    return true;
  }

  bool _columnComplete(int col) {
    for (var row = 0; row < 5; row++) {
      if (!_marked.contains(Tuple2<int, int>(row, col))) {
        return false;
      }
    }
    return true;
  }
}

class BingoBoardResult {
  final int? winIndex;
  final int? score;

  BingoBoardResult.incomplete() : winIndex = null, score = null;
  BingoBoardResult.complete(int this.winIndex, int this.score);

  bool get complete => winIndex != null;
}