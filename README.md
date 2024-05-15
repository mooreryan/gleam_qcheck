# qcheck

QuickCheck-inspired property-based testing with integrated shrinking for [Gleam](https://gleam.run/).

Rather than specifying test cases manually, you describe the invariants that values of a given type must satisfy ("properties").  Then, generators generate lots of values (test cases) on which the properties are checked.  Finally, if a value is found for which a given property does not hold, that value is "shrunk" in order to find an nice, informative counter-example that is presented to you.

While there are a ton of great articles introducing quickcheck or property-based testing, here are a couple general resources that you may enjoy:

- [An introduction to property based testing](https://fsharpforfunandprofit.com/pbt/)
- [What is Property Based Testing?](https://hypothesis.works/articles/what-is-property-based-testing/)

## Usage

The main modules that you will be interacting with are `qcheck/qtest` and `qcheck/generator`.

- `qcheck/qtest` contains the functions used to actually run the property tests.
  - `qcheck/qtest/config` contains functions and types for setting the configuration options for the property tests.
- `qcheck/generator` contains the functions used to generate the values that drive the property tests, as well as additional tools for creating your own generators.

### Basic example

Here is a short example to get you started.  It assumes you are using [gleeunit](https://github.com/lpil/gleeunit) to run the tests, but any test runner that reasonably handles panics will do.


```gleam
import qcheck/generator
import qcheck/qtest

pub fn small_positive_or_zero_int__test() {
  use n <- qtest.given(generator.small_positive_or_zero_int())
  n + 1 == 1 + n
}

pub fn small_positive_or_zero_int__failures_shrink_to_zero__test() {
    use n <- qtest.given(generator.small_positive_or_zero_int())
    n + 1 != 1 + n
}
```

That second example will fail with an error that may look something like this if you are targeting Erlang.

```
 Failures:

   1) qcheck/gen_int_test.small_positive_or_zero_int__failures_shrink_to_zero__test
      Failure: <<"TestError[original_value: 10; shrunk_value: 0; shrink_steps: 1;]">>
      stacktrace:
        qcheck_ffi.fail
      output: 
```

- `qtest.given` sets up the test
  - If a property holds for all generated values, then `qtest.given` returns `Nil`.
  - If a property does not hold for all generated values, then `qtest.given` will panic.
- `generator.small_positive_or_zero_int()` generates small integers greater than or equal to zero.
- `n + 1 == 1 + n` is the property being tested in the first test.
  - It should be true for all generated values.
  - The return value of `qtest.given` will be `Nil`, because the property does hold for all generated values.
- `n + 1 != 1 + n` is the property being tested in the second test. 
  - It should be false for all generated values.
  - `qtest.given` will be panic, because the property does not hold for all generated values.

### In-depth example

Here is a more in-depth example.  We will create a simple `Point` type write some serialization functions, and then check that the serializing round-trips.

First here is some code to define a `Point`.

```gleam
type Point {
  Point(Int, Int)
}

fn make_point(x, y) {
  Point(x, y)
}

/// Checks if two points are equal.
fn make_point(x: Int, y: Int) -> Point {
  Point(x, y)
}

/// Serialize a point to a string.
/// 
/// `point_to_string(Point(1, 2)) // -> (1 2)
fn point_to_string(point: Point) -> String {
  let Point(x, y) = point
  "(" <> int.to_string(x) <> " " <> int.to_string(y) <> ")"
}
```

Next, let's write a function that parses the string representation into a `Point`.  The string representation is pretty simple, `Point(1, 2)` would be represented by the following string: `(1 2)`.

Here is one possible way to parse that string representation into a `Point`.

```gleam
fn point_of_string(string: String) -> Result(Point, String) {
  // Create the regex.
  use re <- result.try(
    regex.from_string("\\((\\d+) (\\d+)\\)")
    |> result.map_error(string.inspect),
  )

  // Ensure there is a single match.
  use submatches <- result.try(case regex.scan(re, string) {
    [Match(_content, submatches)] -> Ok(submatches)
    _ -> Error("expected a single match")
  })

  // Ensure both submatches are present.
  use xy <- result.try(case submatches {
    [Some(x), Some(y)] -> Ok(#(x, y))
    _ -> Error("expected two submatches")
  })

  // Try to parse both x and y values as integers.
  use xy <- result.try(case int.parse(xy.0), int.parse(xy.1) {
    Ok(x), Ok(y) -> Ok(#(x, y))
    Error(Nil), Ok(_) -> Error("failed to parse x value")
    Ok(_), Error(Nil) -> Error("failed to parse y value")
    Error(Nil), Error(Nil) -> Error("failed to parse x and y values")
  })

  Ok(Point(xy.0, xy.1))
}
```

Now we would like to test our implementation.  Of course, we could make some examples and test it like so:

```gleam
import gleeunit/should

pub fn roundtrip_test() {
  let point = Point(1, 2)
  let parsed_point = point |> point_to_string |> point_of_string

  point_equal(point, parsed_point) |> should.be_true
}
```

That's fine, and you can imagine taking some corner cases like putting in `0` or `-1` or the max and min values for integers on your selected target.  Rather, let's think of a property to test.  

I mention round-tripping, but how can you write a property to test it.  Something like, "given a valid point, when serializing it to a string, and then deserializing that string into another point, both points should always be equal".  

Okay, first we need to write a generator of valid points.  In this case, it isn't too interesting as any integer can be used for both `x` and `y` values of the point.  So we can use `generator.map2` like so:

```gleam
fn point_generator() {
  generator.map2(make_point, generator.int_uniform(), generator.int_uniform())
}
```

Alternatively, if you prefer the `use` syntax, you could write: 

```gleam
fn point_generator() {
  use x, y <- generator.map2(
    g1: generator.int_uniform(),
    g2: generator.int_uniform(),
  )

  make_point(x, y)
}
```

Now that we have the point generator, we can write a property test.

```gleam
pub fn point_serialization_roundtripping__test() {
  use generated_point <- qtest.given(point_generator())

  let assert Ok(parsed_point) =
    generated_point
    |> point_to_string
    |> point_of_string

  point_equal(generated_point, parsed_point)
}
```

A couple things to note here.

- `qtest.given` will "fail" if either the property doesn't hold (e.g., returns `False`) or if there is a panic somewhere in the property function.
  - Either, the points are not equal, or, the deserialization returns an `Error` (because we `assert` that it is `Ok`).
  - Either one of these cases will trigger shrinking.

Let's try and run the test.

```
$ gleam test

  1) examples/parsing_example_test.point_serialization_roundtripping__test: module 'examples@parsing_example_test'
     Failure: <<"TestError[original_value: Point(-875333649, -1929681101); shrunk_value: Point(0, -1); shrink_steps: 31; error: Errored(dict.from_list([#(Function, \"point_serialization_roundtripping__test\"), #(Line, 74), #(Message, \"Assertion pattern match failed\"), #(Module, \"examples/parsing_example_test\"), #(Value, Error(\"expected a single match\")), #(GleamError, LetAssert)]));]">>
     stacktrace:
       qcheck_ffi.fail
     output: 
```

There is a failure.  Now, currently, this output is pretty noisy.  Here are the important parts to highlight.

- `original_value: Point(-875333649, -1929681101)`
  - This is the original counter-example that causes the test to fail.
- `shrunk_value: Point(0, -1)`
  - Because `qcheck` generators have integrated shrinking, that counter-example "shrinks" to this simpler example.
  - The "shrunk" examples can help you better identify what the problem may be.
- `Error(\"expected a single match\"))`
  - Here is the error message that actually caused the failure.

So we see a failure with `Point(0, -1)`, which means it probably has something to do with the negative number.  Also, we see that the `Error("expected a single match")` is what triggered the failure.  That error comes about when `regex.scan` fails in the `point_of_string` function.  

Given those two pieces of information, we can infer that the issue is in our regular expression definition: `regex.from_string("\\((\\d+) (\\d+)\\)")`.  And now we may notice that we are not allowing for negative numbers in the regular expression.  To fix it, change that line to the following: 

```gleam
    regex.from_string("\\((-?\\d+) (-?\\d+)\\)")
```

That is allowing an optional `-` sign in front of the integers.  Now when you rerun the `gleam test`, everything passes.

You could imagine combining a property test like the one above, with a few well chosen examples to anchor everything, into a nice little test suite that exercises the serialization of points in a small amount of test code.

(The full code for this example can be found in `test/examples/parsing_example_test.gleam`.)


### More examples

The [test](https://github.com/mooreryan/gleam_qcheck/tree/main/test) directory of this repository has many examples of setting up tests, using the built-in generators, and creating new generators.  Until more dedicated documentation is written, the tests can provide some good info, as they exercise most of the available behavior of the `qtest` and `generator` modules.  However, be aware that the tests will often use `use <- err.rescue`.  This is *not* needed in your tests--it provides a way to test the `qcheck` internals.

### Integrating with testing frameworks

You don't have to do anything special to integrate `qcheck` with a testing framework like [gleeunit](https://github.com/lpil/gleeunit).  The only thing required is that your testing framework of choice be able to handle panics/exceptions.

You may also be interested in [qcheck_gleeunit_utils](https://github.com/mooreryan/qcheck_gleeunit_utils) for running your tests in parallel and controlling test timeouts when using gleeunit and targeting Erlang.

## Roadmap

While `qcheck` has a lot of features needed to get started with property-based testing, there are still things that could be added or improved.

See the `ROADMAP.md` for more information.

## Acknowledgements

Very heavily inspired by the [qcheck](https://github.com/c-cube/qcheck) and [base_quickcheck](https://github.com/janestreet/base_quickcheck) OCaml packages, and of course, the Haskell libraries from which they take inspiration.

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
