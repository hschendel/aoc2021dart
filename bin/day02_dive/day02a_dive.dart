import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('input.txt');
  try {
    final submarine = await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .map((line) => _DiveCommand.fromString(line))
        .fold<_Submarine>(_Submarine(),
            (submarine, command) => submarine.applyCommand(command));
    final answer = submarine.depth * submarine.position;
    stdout.writeln(answer);
  } catch (e) {
    stderr.addError(e);
  }
}

class _Submarine {
  int _position;
  int _depth;

  _Submarine({int position = 0, int depth = 0})
      : _position = position,
        _depth = depth;

  _Submarine applyCommand(_DiveCommand command) {
    switch (command.type) {
      case _DiveCommandType.forward:
        _position += command.param;
        return this;
      case _DiveCommandType.up:
        _depth -= command.param;
        if (_depth < 0) {
          throw UnsupportedError("depth < 0");
        }
        return this;
      case _DiveCommandType.down:
        _depth += command.param;
        return this;
    }
  }

  int get position => _position;
  int get depth => _depth;
}

enum _DiveCommandType { forward, down, up }

class _DiveCommand {
  static final RegExp _parseRegExp =
      RegExp(r"^(forward|down|up) (\d+)$", unicode: true);
  late final _DiveCommandType type;
  late final int param;

  _DiveCommand(this.type, this.param);

  _DiveCommand.fromString(String s) {
    final match = _parseRegExp.firstMatch(s);
    if (match == null) {
      throw FormatException("invalid command", s);
    }
    switch (match.group(1)) {
      case "forward":
        type = _DiveCommandType.forward;
        break;
      case "down":
        type = _DiveCommandType.down;
        break;
      case "up":
        type = _DiveCommandType.up;
        break;
      default:
        throw UnimplementedError("unknown command type ${match.group(1)}");
    }
    param = int.parse(match.group(2)!);
    if (param < 0) {
      throw FormatException("parameter must not be < 0", s);
    }
  }
}
