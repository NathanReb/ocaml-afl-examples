# OCaml AFL fuzzing examples

Small examples of how to use AFL to fuzz OCaml programs

These examples are here to help you quickly get set up with AFL and to illustrate an upcoming
article on the [Tarides blog](https://tarides.com/blog.html).

## Setup

To be able to correctly run the examples in this repo and toy around with fuzzing you will need to
install `afl` and have a `+afl` opam switch so that the binaries are properly instrumented for
fuzzing.

You can setup the afl switch by running:
```
$ opam switch create fuzzing-switch 4.07.1+afl
```

You can either install AFL from your distribution, e.g. on Debian:
```
$ apt update && apt install afl
```

Or by using the convenience opam package:
```
$ opam install --switch=fuzzing-switch afl
```

Some of the examples have extra dependencies such as `crowbar` and `bun`. You can install all of them by
running:

```
$ opam install --switch=fuzzing-switch crowbar bun
```

## Simple parser

The `simple-parser` folder contains the most basic example and shows how you can use afl-fuzz to fuzz a
simple parsing function written in OCaml. 

The `lib` subfolder contains a library with a single `parse_int` function that parses an int from a
string, with a little twist.

The `fuzz` subfolder contains the code to be compiled to the fuzzing binary `fuzz.exe` which must be
passed to afl and an `inputs/` folder with a couple starting test cases.

You can try fuzzing it by yourself:
```
$ dune build simple-parser/fuzz/fuzz.exe
$ afl-fuzz -i simple-parser/fuzz/inputs -o _build/default/simple-parser/fuzz/findings _build/default/simple-parser/fuzz/fuzz.exe @@
```

Or simply run:
```
$ dune build @fuzz-simple-parser --no-buffer
```

which will do pretty much exactly the above.

AFL should find the crash fairly quickly. It will show up in the top right corner of `afl-fuzz`'s
output, under `uniq crashes`, see the picture below.

![afl-output-screenshot-emphasized-crashes](img/afl-output-screenshot-emphasized-crashes.png)

You can inspect the input that triggered the crash by running:
```
$ cat _build/default/simple-parser/fuzz/findings/crashes/id*
```

and reproduce it by running:
```
$ ./_build/default/simple-parser/fuzz/fuzz.exe _build/default/simple-parser/fuzz/findings/crashes/id*
```

## Awesome list

The `awesome-list` folder contains an example of how AFL can be used conjointly with the `crowbar`
library to both find crashes and do some property based testing.

The `lib` subfolder contains a library with a single `sort` function that sorts lists of integers.
Again it mostly works fine except in two specific cases where it will either crash or sort the list
in reverse order.

The `fuzz` subfolder contains the code for the fuzzing binary. It is slightly different from the
previous example as here we use `crowbar` to build the correct binary instead of doing it by hand.
Furthermore, we don't check for crashes only anymore but also want to know if the function under
test invariant, i.e. the resulting list is sorted in increasing order, stands. The resulting fuzzing
binary has roughly two modes of execution: an AFL one and a QuickCheck one.

In QuickCheck mode it uses OCaml's randonmess source to try a fixed number of inputs. To try that
mode you can run:
```
$ dune exec awesome-list/fuzz/fuzz.exe
```

Alternatively you can also run the QuickCheck mode until a test failure is discovered with the `-i`
option of the binary like this:
```
$ dune exec -- awesome-list/fuzz/fuzz.exe -i
```

In AFL mode, it just use the input supplied by AFL as a source of randomness to supply values of the
right form to your test functions. You can run it just like with a regular fuzzing binary:
```
$ dune build awesome-list/fuzz/fuzz.exe
$ afl-fuzz -i awesome-list/fuzz/inputs -o _build/default/awesome-list/fuzz/findings ./_build/default/awesome-list/fuzz/fuzz.exe @@
```

Or use the convenience dune alias:
```
$ dune build @fuzz-awesome-list
```

Both modes should find the bugs in a split second. In QuickCheck mode it'll pretty print the input
value that triggered the failure. In AFL mode you can proceed as in the above example, i.e. kill the
`afl-fuzz` process once it found the two unique crashes. From there, inspecting the input files
won't tell you much as it's just used to seed `crowbar` PRNG but you can run the fuzz binary on
those and the input values will be pretty printed the same way they are in QuickCheck mode:
```
$ ./_build/default/awesome-list/fuzz/fuzz.exe ./_build/default/awesome-list/fuzz/findings/crashes/<input_file>
```
