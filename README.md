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

## Day 1

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

## Day 2

The stream based approach using `fold` still works. Also, I learned to use regular expressions
in Dart.

## Day 3

For the first part, the stream's `fold` method was sufficient again.
For the second part I first tried to implement a `StreamTransformer` that does the narrowing
down, but then realized that I need to keep the whole list in memory anyway, so I resorted to
a simple list-based approach. I have the feeling this could have been done better though...

## Day 4

Learned about the `try { ... } on SomeTypeException catch (e) { ... }` syntax.
I miss Go's `defer` to always do `_lineNo++` on exiting `parseLine()`.
On the other hand, my code in Go would probably be less well structured as this Dart code.
That allowed me to easily add the last winning board logic in step two.

## Day 5

In step 2 I realized that I should have followed Eric's lead to just draw the lines into a map,
instead of the complex and test intensive OOP monster I created. Still, it works. But next
time, I will go for the simple and stupid approach. Really.

## Day 6

This is the exponential growth trap. And who does not know about it nowadays in times of the
pandemic? Still, for step 1 I let myself led by input format, using that to represent the state
of the fish population. Which of course does not work for 256 days. So, the input format has
to be replaced by something more up to the job - a list of counts by "fish state" (0 to 8).

I also learned something about Dart's lists. If you use this, the number of elements in the list
cannot be changed (in Dart speak it is not growable):

```dart
final List<int> _counts = List.filled(9, 0);
```

But my `day()` method left-shifts `_counts`, and then adds the new fish at the end, and
also adds to position 6 the count of the fishes that spawn. So I have to write:

```dart
final List<int> _counts = List.filled(9, 0, growable: true);
```

Interesting. That is how Dart tries to cope with the absence of real arrays then ;)

## Day 7

This time I learned about the `~/` operator for integer division.
Other than that I think for step two it was important complexity-wise to use the closed term
`(dist + 1) * dist ~/ 2` for the fuel cost of one move instead of a for loop.
Also, my first idea was something like a binary search to reduce time complexity,
but nevertheless the straightforward approach worked fine.

## Day 8

Learned about type qualification using the `is` operator. Also about what to override in order
to efficiently use a type as a key for `Map`. Java is calling ;)
For step 2 I again wasted a lot of time on trying to build some algorithmic learning crap. Then I
reconsidered, and resorted to dynamic programming. There are only 7! = 5040 different mappings
of the segments to each other. To generate the lookup map, I used Dart's recursive generator
feature using `yield*`. Came in handy here.

## Day 9

In the second part I had a bit of a bad gut feeling about how to count basins that are separated
from their neighbour not by a 9. But the input contains lot of nines, and my recursive implementation
worked just fine. I start to like `List`'s expressiveness, e.g. here

```dart
sizes.reversed.take(3).fold(1, (product, size) => product * size)
```

## Day 10

That one felt easy to me, as I was lucky starting with a parser stack that I could then
use to solve part 2.

## Day 11

Again, Dart's generator construct looks like it was just added for algorithmic gymnastics like
these, where I need to iterate over an octopuses' neighbours.

```dart
Iterable<Point<int>> neighbours(int x, int y) sync* { ... }
```

Other than that, not much to see here.

## Day 12

It is a good thing that two big caves are never connected. Other than that, in part 2
I first got a stack overflow. As my `visited` set is passed up and down the call stack
it has to be left clean. I did forget that if I was using a small cave twice, it must not
be removed from the `visited` set. With a functional implementation I would not have run into this bug.

## Day 13

The pattern of using the parser on a stream continues to work well. Other than that, nothing to
see here. I was a bit unsure if the part two also asks us to implement some kind of character
recognition, but I decided to ignore that doubt ;)

## Day 14

Part two took me some thinking. Good thing is I was traveling, so I was not able to waste to much
time coding. The simple realization that I only need to count the insertions came to me while driving :D
Other than that I learned the correct operator precedence for `??` through

```dart
elemCount[ch] = (elemCount[ch] ?? 0) + 1;
```

Try leaving the parentheses away and you will get surprising results.

## Day 15

Choosing the A* algorithm turned out to work even for the expanded map in part two. Also, my
Dart implementation of A* looks very readable to me.

## Day 16

I learned a bit more about stream processing. If you write a recursive-descent parser,
`StreamIterator` is a good fit.

## Day 17

I overcomplicated this thing. Again a lesson about doing it simple first.

This smells like constraint programming. If we need the y velocity to be negative, we could reformulate
the problem by always subtracting the target max y from the y velocity, so it can always be positive.
We could also flip the x axis, if the target area is to the left. But looking at the input,
all this can be ignored.

Still, with my limited math knowledge, I was not able to come up with a simple solver for this,
as the formula is not linear thanks to drag and velocity. A few things are worth noting:

- x always converges after x velocity steps
- 1 is a good lower bound for the x velocity, as the target x values are positive
- maxX is a good upper bound for the x velocity
- minX is a good lower bound for the y velocity
- for a positive initial y velocity, the "re-entry" velocity at y=0 is so high that when we
  take -minY as the initial y velocity, it will skip the target area. So we can use it as the
  upper bound for the y velocity.

## Day 18

Almost straightforward. The complex definition of explode and split made unit tests necessary.

## Day 19

Again, unit testing was absolutely necessary ;-) The difference in the merge loop in part two is
due to me grudgingly accepting that somehow the input does not need to merge some two other
scanners to be able to match at least one scanner with scanner 0. That made the tracking of
the scanner positions easier.
I start to appreciate how Dart helps me structure code.

## Day 20

It all sounded straightforward. But what I did not understand at first was that the infinite
background flips in the real input. First time I had to go hunting for hints on the subreddit.

## Day 21

Part one and two felt a bit unrelated, with part two reminding me immediately about day 14.
So we have to operate on the "universe counts". Implementing a good representation with Dart
went well.

## Day 22

Applied set theory. Dart's generator feature was again helpful. I start to grasp Dart's good
expressiveness while maintaining readability.