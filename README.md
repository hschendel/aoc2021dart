# Advent of Code 2021 in Dart

This is my attempt to solve the [Advent of Code 2021](https://adventofcode.com/2021) using Dart. My idea to
do this in Dart came from my first experience with [Flutter](https://flutter.dev) which I find a
very interesting approach to frontend and app development. I do not really like Dart, as for my
taste it looks to much like the mess C# has become and not enough like elegant Go (missing stuff
like multiple return values, anonymous structs in test cases, the ease of using JSON, ...). Still,
it is not too bad, the named parameters make Flutter code readable, the magic around constructors
does help to ease the yoke of a full-blown OOP language.

So, in order to better understand Dart, the Advent of Code looked like a good idea. I started late
on day 6 on my spare time, and while my understanding of Dart seems to be growing every day, this is not
picture perfect Dart code. So please do not let yourself be misguided on your Dart journey.
If you have suggestions on how to do thinks better, I would be pleased to learn from you :)

# Day 1

Until today I never processed a file in Dart. A bit of searching led me to the stream based
approach that seems to be idiomatic Dart:

```dart
final file = File('input.txt');
  Stream<String> lines =
      file.openRead().transform(utf8.decoder).transform(LineSplitter());
```

This in turn led me to write a [stream transformer](https://api.dart.dev/stable/2.15.0/dart-async/StreamTransformer-class.html)
collecting the sliding window sums. The of course the counting of the increases could be done
using the stream's `fold` method.
So already for day 1 I learned a lot about Dart streams I did not know beforehand :)

# Day 2

The stream based approach using `fold` still works. Also, I learned to use regular expressions
in Dart.

# Day 3

For the first part, the stream's `fold` method was sufficient again.
For the second part I first tried to implement a `StreamTransformer` that does the narrowing
down, but then realized that I need to keep the whole list in memory anyway, so I resorted to
a simple list-based approach. I have the feeling this could have been done better though...

# Day 4

Learned about the `try { ... } on SomeTypeException catch (e) { ... }` syntax.
I miss Go's `defer` to always do `_lineNo++` on exiting `parseLine()`.
On the other hand, my code in Go would probably be less well structured as this Dart code.
That allowed me to easily add the last winning board logic in step two.