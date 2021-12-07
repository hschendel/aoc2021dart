My attempt to solve the Advent of Code using Dart.

# Day 3

For the first part, the stream's `fold` method was sufficient again.
For the second part I first tried to implement a `StreamTransformer` that does the narrowing
down, but then realized that I need to keep the whole list in memory anyway, so I resorted to
a simple list-based approach. I have the feeling this could have been done better though...

