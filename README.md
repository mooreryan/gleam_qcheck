# qcheck

QuickCheck-inspired property-based testing with integrated shrinking for [Gleam](https://gleam.run/).

Rather than specifying test cases manually, you describe the invariants that values of a given type must satisfy ("properties"). Then, generators generate lots of values (test cases) on which the properties are checked. Finally, if a value is found for which a given property does not hold, that value is "shrunk" in order to find an nice, informative counter-example that is presented to you.

While there are a ton of great articles introducing quickcheck or property-based testing, here are a couple general resources that you may enjoy:

- [An introduction to property based testing](https://fsharpforfunandprofit.com/pbt/)
- [What is Property Based Testing?](https://hypothesis.works/articles/what-is-property-based-testing/)

You might also be interested in checking out [this project](https://github.com/mooreryan/gleam_stdlib_testing) that uses qcheck to test Gleam's stdlib.

## Usage & Examples

- See the API docs for detailed usage,
- See [qcheck_viewer](https://mooreryan.github.io/gleam_qcheck/) to visualize the distributions of some of the qcheck generators.

### Basic example

Here is a short example to get you started. It assumes you are using [gleeunit](https://github.com/lpil/gleeunit) to run the tests, but any test runner that reasonably handles panics will do.

```gleam
import qcheck

pub fn int_addition_commutativity__test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())
  should.equal(n + 1, 1 + n)
}

pub fn int_addition_commutativity__failures_shrink_to_zero__test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())
  should.not_equal(n + 1, 1 + n)
}
```

Let's go through the code:

- `qcheck.given` sets up the test
  - If a property holds for all generated values, then `qcheck.given` returns `Nil`.
  - If a property does not hold for all generated values, then `qcheck.given` will panic.
- `qcheck.small_non_negative_int()` generates small integers greater than or equal to zero.
- `assert n + 1 == 1 + n` is the property being tested in the first test.
  - It should be true for all generated values.
  - The return value of `qcheck.given` will be `Nil`, because the property does hold for all generated values.
  - You can use Gleam's `assert` keyword to get nicer error messages
- `assert n + 1 != 1 + n` is the property being tested in the second test.
  - It should be false for any generated values.
  - `qcheck.given` will be panic, because the property does not hold for any generated values.

If you run it, that second example will fail with an error that may look something like this if you are targeting Erlang.

```
panic src/qcheck.gleam:2833
 test: examples@basic_example_test.int_addition_commutativity__failures_shrink_to_zero__test
 info: a property was falsified!
qcheck assert test/examples/basic_example_test.gleam:12
 code: assert n + 1 != 1 + n
 left: 4
right: 4
 info: Assertion failed.
qcheck shrinks
 orig: 3
shrnk: 0
steps: 1
```

The error message gives some info to help you diagnose the issue. Since we used `assert`, we get some info about the code that was run, it's location in the test file, the values on the left and right side.
Additionally, there is some info about the "shrinking". You will see:

- `orig`, which lists the original generated value that triggered the error
- `shrnk`, which shows the "shrunk" value.
  - I.e., a value that is usually easiear to interpret.
  - In this example `3` and `0` aren't too bad, but you will often see shrunk values that look like this: `#(Some(0), None, None, None, None)` which is much easier to figure out what the issue might be than something like this: `#(Some(1371457222), Some(369023.1034975077), Some(True), Some("2x"), None)`.
  - (That is a real result from a property test I intionally broke for illustration from the [bsql3](https://github.com/mooreryan/bsql3/blob/b0d60113e83a8a30b00660b1190b0334be6a04a7/test/bsql3_test.gleam#L245) repository.)
- `steps`, which shows the number of "shrink steps" it took to get to the shrunk value.
  - If this is really high, you may need to adjust your generation process.

### In-depth example

Here is a more in-depth example. We will create a simple `Point` type, write some serialization functions, and then check that the serializing round-trips.

First, here is some code to define a `Point`, and a `to_string` function that makes a string representation like this: `(x y)`.

```gleam
type Point {
  Point(Int, Int)
}

fn point_to_string(point: Point) -> String {
  let Point(x, y) = point
  "(" <> int.to_string(x) <> " " <> int.to_string(y) <> ")"
}
```

Next, let's write a function that parses the string representation into a `Point`. The string representation is pretty simple, `Point(1, 2)` would be represented by the following string: `(1 2)`.

Here is one possible way to parse that string representation into a `Point`. (Note that this implementation is intentionally broken for illustration.)

```gleam
fn point_from_string(string: String) -> Result(Point, String) {
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

Now we would like to test our implementation. Of course, we could make some examples and test it like so:

```gleam
pub fn roundtrip_test() {
  let point = Point(1, 2)
  let parsed_point = point |> point_to_string |> point_of_string

  assert point == parsed_point
}
```

That's good, and you can imagine taking some corner cases like putting in `0` or `-1` or the max and min values for integers on your selected target. I think you should still test some interesting cases manually to "anchor" your test suite. But, let's think of a property to test.

I mention round-tripping, but how can you write a property to test it. Something like, "given a valid point, when serializing it to a string, and then deserializing that string into another point, both points should always be equal".

Okay, first we need to write a generator of valid points. In this case, it isn't too tricky as any integer can be used for both `x` and `y` values of the point. So we can use `generator.map2` like so:

```gleam
fn point_generator() {
  qcheck.map2(qcheck.uniform_int(), qcheck.uniform_int(), Point)
}
```

For illustration, you could also utilize the `use` syntax. You could write:

```gleam
fn point_generator() {
  use x, y <- qcheck.map2(qcheck.uniform_int(), qcheck.uniform_int())
  Point(x, y)
}
```

Now that we have the point generator, we can write a property test.

```gleam
pub fn point_serialization_roundtripping__test() {
  use generated_point <- qcheck.given(point_generator())

  let assert Ok(parsed_point) =
    generated_point |> point_to_string |> point_from_string

  assert generated_point == parsed_point
}
```

Let's try and run the test. You should see an error that looks something like this:

```
panic src/qcheck.gleam:2833
 test: examples@parsing_example_test.point_serialization_roundtripping__test
 info: a property was falsified!
qcheck let assert test/examples/parsing_example_test.gleam:62
 code: let assert Ok(parsed_point) =
    generated_point |> point_to_string |> point_from_string
value: Error("expected a single match")
 info: Pattern match failed, no pattern matched the value.
qcheck shrinks
 orig: Point(-1827478708, -274074946)
shrnk: Point(0, -1)
steps: 29
```

Here are the important parts to highlight.

- original value: `Point(-1827478708, -274074946)`
  - This is the original counter-example that causes the test to fail.
- shrunk value: `Point(0, -1)`
  - Because `qcheck` generators have integrated shrinking, that counter-example "shrinks" to this simpler example.
  - The "shrunk" examples can help you better identify what the problem may be.
- `Error("expected a single match")`
  - Here is the error message that actually caused the failure.

Let me point out that you could write this test in a slightly different way and get what I think is a bit better output:

```gleam
pub fn point_serialization_roundtripping__test() {
  use generated_point <- qcheck.given(point_generator())

  let parsed_point = generated_point |> point_to_string |> point_from_string

  assert Ok(generated_point) == parsed_point
}
```

Which would output:

```
panic src/qcheck.gleam:2833
 test: examples@parsing_example_test.point_serialization_roundtripping__assert__test
 info: a property was falsified!
qcheck assert test/examples/parsing_example_test.gleam:56
 code: assert Ok(generated_point) == parsed_point
 left: Ok(Point(-694965642, -939456627))
right: Error("expected a single match")
 info: Assertion failed.
qcheck shrinks
 orig: Point(-694965642, -939456627)
shrnk: Point(0, -1)
steps: 30
```

Either way is fine, but I think the second way gives a bit more clarity.

Anyway, back to interpreting the failure. So we see a failure with `Point(0, -1)`, which means it probably has something to do with the negative number. Also, we see that the `Error("expected a single match")` is what triggered the failure. That error comes about when `regex.scan` fails in the `point_from_string` function.

Given those two pieces of information, we can infer that the issue is probably in our regular expression definition: `regex.from_string("\\((\\d+) (\\d+)\\)")`. And now we may notice that we are not allowing for negative numbers in the regular expression. To fix it, change that line to the following:

```gleam
    regex.from_string("\\((-?\\d+) (-?\\d+)\\)")
```

That is allowing an optional `-` sign in front of the integers. Now when you rerun the `gleam test`, everything passes.

You could imagine combining a property test like the one above, with a few well chosen examples to anchor everything, into a nice little test suite that exercises the serialization of points in a small amount of test code.

(The full code for this example can be found in `test/examples/parsing_example_test.gleam`.)

### Applicative style

The applicative style provides a nice interface for creating generators for custom types. When you have independent generators, this way can often given better shrinking then using `bind` when you don't need it.

```gleam
import qcheck

/// A simple Box type with position (x, y) and dimensions (width, height).
type Box {
  Box(x: Int, y: Int, w: Int, h: Int)
}

fn box_generator() {
  // Lift the Box creating function into the Generator structure.
  qcheck.return({
    use x <- qcheck.parameter
    use y <- qcheck.parameter
    use w <- qcheck.parameter
    use h <- qcheck.parameter
    Box(x:, y:, w:, h:)
  })
  // Set the `x` generator.
  |> qcheck.apply(qcheck.bounded_int(-100, 100))
  // Set the `y` generator.
  |> qcheck.apply(qcheck.bounded_int(-100, 100))
  // Set the `width` generator.
  |> qcheck.apply(qcheck.bounded_int(1, 100))
  // Set the `height` generator.
  |> qcheck.apply(qcheck.bounded_int(1, 100))
}
```

You could also write this example using `map4`:

```gleam
fn x_gen() {
  qcheck.bounded_int(-100, 100)
}

fn y_gen() {
  qcheck.bounded_int(-100, 100)
}

fn w_gen() {
  qcheck.bounded_int(1, 100)
}

fn h_gen() {
  qcheck.bounded_int(1, 100)
}

fn box_generator_with_map4() {
  use x, y, w, h <- qcheck.map4(x_gen(), y_gen(), w_gen(), h_gen())
  Box(x:, y:, w:, h:)
}
```

For more info about this, see this [issue](https://github.com/mooreryan/gleam_qcheck/issues/13).

### Integrating with testing frameworks

You don't have to do anything special to integrate `qcheck` with a testing framework like [gleeunit](https://github.com/lpil/gleeunit). The only thing required is that your testing framework of choice be able to handle panics/exceptions.

_Note: [startest](https://github.com/maxdeviant/startest) should be fine. (I last checked it on Jan 6, 2026.)_

You may also be interested in [qcheck_gleeunit_utils](https://github.com/mooreryan/qcheck_gleeunit_utils) for running your tests in parallel and controlling test timeouts when using gleeunit and targeting Erlang.

## Acknowledgements

Very heavily inspired by the [qcheck](https://github.com/c-cube/qcheck) and [base_quickcheck](https://github.com/janestreet/base_quickcheck) OCaml packages.

Check out the `licenses` directory to view their licenses.

## Contributing

Thank you for your interest in the project!

- Bug reports, feature requests, suggestions and ideas are welcomed. Please open an [issue](https://github.com/mooreryan/gleam_qcheck/issues/new/choose) to start a discussion.
- External contributions will generally not be accepted without prior discussion.
  - If you have an idea for a new feature, please open an issue for discussion prior to working on a pull request.
  - Small pull requests for bug fixes, typos, or other changes with limited scope may be accepted. If in doubt, please open an issue for discussion first.

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 - 2026 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
