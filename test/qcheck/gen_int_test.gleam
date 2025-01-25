import gleam/int
import gleam/string
import gleeunit/should
import qcheck

// int_small_positive_or_zero
// 
// 

pub fn int_small_positive_or_zero__test() {
  use n <- qcheck.given(qcheck.int_small_positive_or_zero())
  n + 1 == 1 + n
}

pub fn int_small_positive_or_zero__failures_shrink_to_zero__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    use n <- qcheck.given(qcheck.int_small_positive_or_zero())
    n + 1 != 1 + n
  }

  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(0))
}

pub fn int_small_positive_or_zero__failures_shrink_to_smaller_values__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_positive_or_zero(),
      property: fn(n) { n == 0 || n > 1 },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(1))
}

// int_small_strictly_positive
// 
// 

pub fn int_small_strictly_positive__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.int_small_strictly_positive(),
    property: fn(n) { n > 0 },
  )
}

pub fn int_small_strictly_positive__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_strictly_positive(),
      property: fn(n) { n > 1 },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(1))

  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_strictly_positive(),
      property: fn(n) { n == 1 || n > 2 },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(2))
}

// int_uniform
//
//

pub fn int_uniform__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.int_uniform(),
    property: fn(n) { n + 1 == 1 + n },
  )
}

pub fn int_uniform__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_uniform(),
      property: fn(n) { n < 55_555 },
    )
  }

  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(55_555))
}

pub fn int_uniform__negative_numbers_shrink_towards_zero__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_uniform(),
      // All integers are greater than -5
      property: fn(n) { n > -5 },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(-5))
}

// int_uniform_inclusive
//
//

pub fn int_uniform_range__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_uniform_inclusive(-10, 10),
      property: fn(n) { -5 <= n && n <= 5 },
    )
  }

  let assert Ok(n) =
    qcheck.test_error_message_shrunk_value(msg)
    |> int.parse

  should.be_true(n == -6 || n == 6)
  // case run_result {
  //   // One of either glexer or glance is broken with Error(-6) here, so use the 
  //   // guard for now.
  //   Error(n) if n == -6 || n == 6 -> True
  //   _ -> False
  // }
  // |> should.be_true
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn positive_int_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_uniform_inclusive(5, 10),
      property: fn(n) { 7 <= n && n <= 8 },
    )
  }

  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(5))
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn negative_int_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_uniform_inclusive(-10, -5),
      property: fn(n) { -8 >= n && n >= -7 },
    )
  }

  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(-5))
}

pub fn int_uniform_inclusive__high_less_than_low_ok__test() {
  use n <- qcheck.given(qcheck.int_uniform_inclusive(10, -10))

  -10 <= n && n <= 10
}
