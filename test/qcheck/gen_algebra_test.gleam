import gleam/int
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

// map
//
//

pub fn map__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.default_config(),
      qcheck.small_non_negative_int() |> qcheck.map(int.to_float),
    )

    should.be_true(n == 0.0 || n >. 1.0)
  }

  let shrunk_value = test_error_message.test_error_message_shrunk_value(msg)

  // Value differs on Erlang and JS targets.
  should.be_true(shrunk_value == "1.0" || shrunk_value == "1")
}

fn in_range(min, max) {
  fn(x) { min <= x && x <= max }
}

pub fn map2__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup2 <- qcheck.run(
    qcheck.default_config(),
    qcheck.map2(gen_int, gen_int, fn(a, b) { #(a, b) }),
  )
  let #(a, b) = tup2
  should.be_true(in_range(a) && in_range(b))
}

pub fn map3__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup3 <- qcheck.run(
    qcheck.default_config(),
    qcheck.map3(gen_int, gen_int, gen_int, fn(a, b, c) { #(a, b, c) }),
  )
  let #(a, b, c) = tup3
  should.be_true(in_range(a) && in_range(b) && in_range(c))
}

pub fn map4__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup4 <- qcheck.run(
    qcheck.default_config(),
    qcheck.map4(gen_int, gen_int, gen_int, gen_int, fn(a, b, c, d) {
      #(a, b, c, d)
    }),
  )
  let #(a, b, c, d) = tup4
  should.be_true(in_range(a) && in_range(b) && in_range(c) && in_range(d))
}

pub fn map5__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup5 <- qcheck.run(
    qcheck.default_config(),
    qcheck.map5(gen_int, gen_int, gen_int, gen_int, gen_int, fn(a, b, c, d, e) {
      #(a, b, c, d, e)
    }),
  )
  let #(a, b, c, d, e) = tup5

  should.be_true(
    in_range(a) && in_range(b) && in_range(c) && in_range(d) && in_range(e),
  )
}

pub fn map6__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup6 <- qcheck.run(
    qcheck.default_config(),
    qcheck.map6(
      gen_int,
      gen_int,
      gen_int,
      gen_int,
      gen_int,
      gen_int,
      fn(a, b, c, d, e, f) { #(a, b, c, d, e, f) },
    ),
  )

  let #(a, b, c, d, e, f) = tup6

  should.be_true(
    in_range(a)
    && in_range(b)
    && in_range(c)
    && in_range(d)
    && in_range(e)
    && in_range(f),
  )
}

pub fn map4_with_apply__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  let generator =
    qcheck.return({
      use a <- qcheck.parameter
      use b <- qcheck.parameter
      use c <- qcheck.parameter
      use d <- qcheck.parameter
      #(a, b, c, d)
    })
    |> qcheck.apply(gen_int)
    |> qcheck.apply(gen_int)
    |> qcheck.apply(gen_int)
    |> qcheck.apply(gen_int)

  use tup4 <- qcheck.run(qcheck.default_config(), generator)

  let #(a, b, c, d) = tup4

  should.be_true(in_range(a) && in_range(b) && in_range(c) && in_range(d))
}

pub fn tuple2__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup2 <- qcheck.run(
    qcheck.default_config(),
    qcheck.tuple2(gen_int, gen_int),
  )

  let #(a, b) = tup2

  should.be_true(in_range(a) && in_range(b))
}

pub fn tuple3__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup3 <- qcheck.run(
    qcheck.default_config(),
    qcheck.tuple3(gen_int, gen_int, gen_int),
  )

  let #(a, b, c) = tup3
  should.be_true(in_range(a) && in_range(b) && in_range(c))
}

pub fn tuple4__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup4 <- qcheck.run(
    qcheck.default_config(),
    qcheck.tuple4(gen_int, gen_int, gen_int, gen_int),
  )
  let #(a, b, c, d) = tup4
  should.be_true(in_range(a) && in_range(b) && in_range(c) && in_range(d))
}

pub fn tuple5__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup5 <- qcheck.run(
    qcheck.default_config(),
    qcheck.tuple5(gen_int, gen_int, gen_int, gen_int, gen_int),
  )
  let #(a, b, c, d, e) = tup5
  should.be_true(
    in_range(a) && in_range(b) && in_range(c) && in_range(d) && in_range(e),
  )
}

pub fn tuple6__test() {
  let min = -100
  let max = 100

  let in_range = in_range(min, max)

  let gen_int = qcheck.bounded_int(min, max)

  use tup6 <- qcheck.run(
    qcheck.default_config(),
    qcheck.tuple6(gen_int, gen_int, gen_int, gen_int, gen_int, gen_int),
  )

  let #(a, b, c, d, e, f) = tup6

  should.be_true(
    in_range(a)
    && in_range(b)
    && in_range(c)
    && in_range(d)
    && in_range(e)
    && in_range(f),
  )
}

// bind
//
// The following tests exercise the shrinking behavior when using bind to
// generate custom types.
//
//

type Either(a, b) {
  First(a)
  Second(b)
}

pub fn shrinking_works_with_bind_and_custom_types_test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      qcheck.default_config(),
      qcheck.uniform_int()
        |> qcheck.bind(fn(n) {
          // n >= 0 here will set the shrinker starting on the `First` case, as that
          // is what 0 will become.
          case n >= 0 {
            True ->
              qcheck.bounded_int(10, 19)
              |> qcheck.map(First)
            False ->
              qcheck.bounded_int(90, 99)
              |> qcheck.map(int.to_float)
              |> qcheck.map(Second)
          }
        }),
      fn(either) {
        // Adding the two extra failing cases for First and Second to test the
        // shrinking.
        case either {
          First(15) -> should.be_true(False)
          First(14) -> should.be_true(False)
          First(_) -> should.be_true(True)
          Second(95.0) -> should.be_true(False)
          Second(94.0) -> should.be_true(False)
          Second(_) -> should.be_true(True)
        }
      },
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("First(14)")
}

pub fn shrinking_works_with_bind_and_custom_types_2_test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      qcheck.default_config(),
      qcheck.uniform_int()
        |> qcheck.bind(fn(n) {
          // n > 0 here will set the shrinker starting on the `Second` case, as that
          // is what 0 will become.
          case n > 0 {
            True ->
              qcheck.bounded_int(10, 19)
              |> qcheck.map(First)
            False ->
              qcheck.bounded_int(90, 99)
              |> qcheck.map(int.to_float)
              |> qcheck.map(Second)
          }
        }),
      fn(either) {
        case either {
          First(15) -> should.be_true(False)
          First(14) -> should.be_true(False)
          First(_) -> should.be_true(True)
          Second(95.0) -> should.be_true(False)
          Second(94.0) -> should.be_true(False)
          Second(_) -> should.be_true(True)
        }
      },
    )
  }

  let shrunk_value = test_error_message.test_error_message_shrunk_value(msg)

  // Value differs on Erlang and JS targets.
  should.be_true(shrunk_value == "Second(94.0)" || shrunk_value == "Second(94)")
}

pub fn shrinking_works_with_bind_and_custom_types_3_test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      qcheck.default_config(),
      qcheck.uniform_int()
        |> qcheck.bind(fn(n) {
          case n > 0 {
            True ->
              qcheck.bounded_int(10, 19)
              |> qcheck.map(First)
            False ->
              qcheck.bounded_int(90, 99)
              |> qcheck.map(int.to_float)
              |> qcheck.map(Second)
          }
        }),
      // None of the `Second` shrinks will trigger a failure.
      fn(either) {
        case either {
          First(15) -> should.be_true(False)
          First(14) -> should.be_true(False)
          _ -> should.be_true(True)
        }
      },
    )
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("First(14)")
}

// apply
//
//

fn curry3(f) {
  fn(a) { fn(b) { fn(c) { f(a, b, c) } } }
}

pub fn apply__test() {
  let tuple3 =
    fn(a, b, c) { #(a, b, c) }
    |> curry3

  let generator =
    tuple3
    |> qcheck.return
    |> qcheck.apply(qcheck.bounded_int(-5, 5))
    |> qcheck.apply(qcheck.bounded_int(-10, 10))
    |> qcheck.apply(qcheck.bounded_int(-100, 100))

  use ns <- qcheck.run(qcheck.default_config(), generator)

  let #(a, b, c) = ns
  let a_prop = -5 <= a && a <= 5
  let b_prop = -10 <= b && b <= 10
  let c_prop = -100 <= c && c <= 100

  should.be_true(a_prop && b_prop && c_prop)
}

pub fn shrinking_works_with_apply__test() {
  let tuple3 =
    fn(a, b, c) { #(a, b, c) }
    |> curry3

  let generator =
    tuple3
    |> qcheck.return
    |> qcheck.apply(qcheck.bounded_int(-5, 5))
    |> qcheck.apply(qcheck.bounded_int(-10, 10))
    |> qcheck.apply(qcheck.bounded_int(-100, 100))

  let assert Error(msg) = {
    use <- test_error_message.rescue

    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -5 <= a && a <= 3
    let b_prop = -10 <= b && b <= 10
    let c_prop = -100 <= c && c <= 100

    should.be_true(a_prop && b_prop && c_prop)
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(4, 0, 0)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -3 <= a && a <= 5
    let b_prop = -10 <= b && b <= 10
    let c_prop = -100 <= c && c <= 100

    should.be_true(a_prop && b_prop && c_prop)
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(-4, 0, 0)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -5 <= a && a <= 5
    let b_prop = -10 <= b && b <= 5
    let c_prop = -100 <= c && c <= 100

    should.be_true(a_prop && b_prop && c_prop)
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(0, 6, 0)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -5 <= a && a <= 5
    let b_prop = -5 <= b && b <= 10
    let c_prop = -100 <= c && c <= 100

    should.be_true(a_prop && b_prop && c_prop)
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(0, -6, 0)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -5 <= a && a <= 5
    let b_prop = -10 <= b && b <= 10
    let c_prop = -100 <= c && c <= 50

    should.be_true(a_prop && b_prop && c_prop)
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(0, 0, 51)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -5 <= a && a <= 5
    let b_prop = -10 <= b && b <= 10
    let c_prop = -50 <= c && c <= 100

    should.be_true(a_prop && b_prop && c_prop)
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(0, 0, -51)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -5 <= a && a <= 3
    let b_prop = -10 <= b && b <= 5
    let c_prop = -100 <= c && c <= 50

    should.be_true(a_prop || b_prop || c_prop)
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal("#(4, 6, 51)")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use ns <- qcheck.run(qcheck.default_config(), generator)

    let #(a, b, c) = ns
    let a_prop = -3 <= a && a <= 3
    let b_prop = -5 <= b && b <= 5
    let c_prop = -50 <= c && c <= 50

    should.be_true(a_prop || b_prop || c_prop)
  }

  let parse_numbers = fn(str) {
    regexp.from_string("#\\((-?\\d+), (-?\\d+), (-?\\d+)\\)")
    // Convert regexp.CompileError to a String
    |> result.map_error(string.inspect)
    // Apply the regular expression
    |> result.map(regexp.scan(_, str))
    // We should see only a single match
    |> result.then(fn(matches) {
      case matches {
        [match] -> Ok(match)
        _ -> Error("expected exactly one match")
      }
    })
    // Get submatches
    |> result.then(fn(match) {
      let regexp.Match(_content, submatches) = match

      case submatches {
        [Some(a), Some(b), Some(c)] -> Ok(#(a, b, c))
        _ -> Error("expected exactly one submatch")
      }
    })
    // Parse to ints
    |> result.then(fn(tup) {
      let #(a, b, c) = tup

      // The way this is set up, the failing values will either be positve or
      // negative for each "slot", so we must map the absolute value.
      case int.parse(a), int.parse(b), int.parse(c) {
        Ok(a), Ok(b), Ok(c) ->
          Ok(#(
            int.absolute_value(a),
            int.absolute_value(b),
            int.absolute_value(c),
          ))
        _, _, _ -> panic
      }
    })
  }

  let assert Ok(numbers) =
    test_error_message.test_error_message_shrunk_value(msg)
    |> parse_numbers

  numbers
  |> should.equal(#(4, 6, 51))
}

pub fn bind_and_then_are_aliases__test() {
  let generator_with_bind = {
    use length <- qcheck.bind(qcheck.small_strictly_positive_int())
    qcheck.bounded_int(0, length)
  }

  let generator_with_then = {
    use length <- qcheck.then(qcheck.small_strictly_positive_int())
    qcheck.bounded_int(0, length)
  }

  use seed <- qcheck.given(qcheck.uniform_int())
  let seed = qcheck.seed(seed)
  let count = 10

  should.equal(
    qcheck.generate(generator_with_bind, count, seed),
    qcheck.generate(generator_with_then, count, seed),
  )
}
