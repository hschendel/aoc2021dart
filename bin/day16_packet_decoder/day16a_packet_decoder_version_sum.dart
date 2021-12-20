import 'dart:async';
import 'dart:io';

void main(List<String> arguments) async {
  final filename = arguments.isNotEmpty ? arguments[0] : "input.txt";
  final file = File(filename);
  try {
    final stream = file
        .openRead()
        .transform(
            StreamTransformer<List<int>, int>.fromHandlers(handleData: (l, s) {
          l.forEach((b) {
            s.add(b);
          });
        }))
        .where((ch) => ch != 13 && ch != 10) // filter line breaks
        .map((ch) => int.parse(String.fromCharCode(ch), radix: 16))
        .transform(bitStream());
    final st = StreamIterator(stream);
    var endOfStream = false;
    var versionSum = 0;
    while (!endOfStream) {
      try {
        final packet = await parsePacket(st);
        versionSum += packet.versionSum;
      } on EndOfStream catch (_) {
        endOfStream = true;
      }
    }
    stdout.writeln("version sum: $versionSum");
  } catch (e) {
    stderr.addError(e);
  }
}

StreamTransformer<int, bool> bitStream({int wordSize = 4}) {
  return StreamTransformer.fromHandlers(handleData: (word, sink) {
    for (var bitI = wordSize - 1; bitI >= 0; bitI--) {
      final bitMask = 1 << bitI;
      sink.add((word & bitMask) != 0);
    }
  }, handleDone: (sink) {
    sink.close();
  });
}

Future<Packet> parsePacket(StreamIterator<bool> st) async {
  final version = await parseInt(st, 3);
  final typeId = await parseInt(st, 3);
  if (typeId == 4) {
    return parseLiteralValueBody(st, version);
  }
  return parseOperatorBody(st, version, typeId);
}

Future<LiteralValue> parseLiteralValueBody(
    StreamIterator<bool> st, int version) async {
  var more = true;
  var value = 0;
  var size = 0;
  while (more) {
    more = (await parseInt(st, 1)) == 1;
    final part = await parseInt(st, 4);
    value = (value << 4) + part;
    size += 5;
  }
  return LiteralValue(version, value, size);
}

Future<Operator> parseOperatorBody(
    StreamIterator<bool> st, int version, int typeId) async {
  final lengthTypePacketCount = (await parseInt(st, 1)) == 1;
  final packets = <Packet>[];
  var size = 1;
  if (lengthTypePacketCount) {
    final packetCount = await parseInt(st, 11);
    size += 11;
    for (var i = 0; i < packetCount; i++) {
      final packet = await parsePacket(st);
      size += packet.size;
      packets.add(packet);
    }
    return Operator(version, typeId, packets, size);
  }
  final bitLength = await parseInt(st, 15);
  size += 15;
  var bitsRead = 0;
  while (bitsRead < bitLength) {
    final packet = await parsePacket(st);
    bitsRead += packet.size;
    packets.add(packet);
  }
  if (bitsRead != bitLength) {
    throw FormatException(
        "packet says it has $bitLength bits for packets, but yielded $bitsRead packet bits");
  }
  size += bitLength;
  return Operator(version, typeId, packets, size);
}

Future<int> parseInt(StreamIterator<bool> st, int size) async {
  var value = 0;
  for (var i = 0; i < size; i++) {
    if (!await st.moveNext()) {
      throw EndOfStream();
    }
    value = (value << 1) + (st.current ? 1 : 0);
  }
  return value;
}

class IntToken {
  final int value;
  final int pos;

  IntToken(this.value, this.pos);
}

abstract class Packet {
  final int version;
  final int typeId;
  final int size;

  Packet(this.version, this.typeId, int size) : size = size + 6;

  int get versionSum;
}

class LiteralValue extends Packet {
  final int value;

  LiteralValue(int version, this.value, int size) : super(version, 4, size);

  @override
  String toString() => "v$version: literal $value";

  @override
  int get versionSum => version;
}

class Operator extends Packet {
  final List<Packet> packets;

  Operator(int version, int typeId, this.packets, int size)
      : super(version, typeId, size);

  @override
  String toString() =>
      "v$version: operator $typeId (${packets.map((p) => p.toString()).join(", ")})";

  @override
  int get versionSum =>
      version + packets.fold<int>(0, (sum, p) => sum + p.versionSum);
}

class EndOfStream implements Exception {}
