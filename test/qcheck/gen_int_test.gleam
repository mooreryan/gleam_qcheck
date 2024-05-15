import gleam/int
import gleam/string
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/qtest/test_error_message as err

// small_positive_or_zero_int
// 
// 

pub fn small_positive_or_zero_int__test() {
  use n <- qtest.given(generator.small_positive_or_zero_int())
  n + 1 == 1 + n
}

pub fn small_positive_or_zero_int__failures_shrink_to_zero__test() {
  let assert Error(msg) = {
    use <- err.rescue
    use n <- qtest.given(generator.small_positive_or_zero_int())
    n + 1 != 1 + n
  }

  err.shrunk_value(msg)
  |> should.equal(string.inspect(0))
}

pub fn small_positive_or_zero_int__failures_shrink_to_smaller_values__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.small_positive_or_zero_int(),
      property: fn(n) { n == 0 || n > 1 },
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(1))
}

// small_strictly_positive_int
// 
// 

pub fn small_strictly_positive_int__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    property: fn(n) { n > 0 },
  )
}

pub fn small_strictly_positive_int__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.small_strictly_positive_int(),
      property: fn(n) { n > 1 },
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(1))

  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.small_strictly_positive_int(),
      property: fn(n) { n == 1 || n > 2 },
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(2))
}

// int_uniform
//
//

pub fn int_uniform__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n + 1 == 1 + n },
  )
}

pub fn int_uniform__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform(),
      property: fn(n) { n < 55_555 },
    )
  }

  err.shrunk_value(msg)
  |> should.equal(string.inspect(55_555))
}

pub fn int_uniform__negative_numbers_shrink_towards_zero__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform(),
      // All integers are greater than -5
      property: fn(n) { n > -5 },
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(-5))
}

// int_uniform_inclusive
//
//

pub fn int_uniform_range__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform_inclusive(-10, 10),
      property: fn(n) { -5 <= n && n <= 5 },
    )
  }

  let assert Ok(n) =
    err.shrunk_value(msg)
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
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform_inclusive(5, 10),
      property: fn(n) { 7 <= n && n <= 8 },
    )
  }

  err.shrunk_value(msg)
  |> should.equal(string.inspect(5))
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn negative_int_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform_inclusive(-10, -5),
      property: fn(n) { -8 >= n && n >= -7 },
    )
  }

  err.shrunk_value(msg)
  |> should.equal(string.inspect(-5))
}
