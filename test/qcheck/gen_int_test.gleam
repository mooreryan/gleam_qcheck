import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

// small_positive_or_zero_int
// 
// 

pub fn small_positive_or_zero_int__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n + 1 == 1 + n },
  )
  |> should.equal(Ok(Nil))
}

pub fn small_positive_or_zero_int__failures_shrink_to_zero__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n + 1 != 1 + n },
  )
  |> should.equal(Error(0))
}

pub fn small_positive_or_zero_int__failures_shrink_to_smaller_values__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n == 0 || n > 1 },
  )
  |> should.equal(Error(1))
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
  |> should.equal(Ok(Nil))
}

pub fn small_strictly_positive_int__failures_shrink_ok__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    property: fn(n) { n > 1 },
  )
  |> should.equal(Error(1))

  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    // This will find a very specific shrunk value.
    property: fn(n) { n == 1 || n > 2 },
  )
  |> should.equal(Error(2))
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
  |> should.equal(Ok(Nil))
}

pub fn int_uniform__failures_shrink_ok__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    // All integers are less than 55,555.
    property: fn(n) { n < 55_555 },
  )
  // Smallest value to falsify the property.
  |> should.equal(Error(55_555))
}

pub fn int_uniform__negative_numbers_shrink_towards_zero__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    // All integers are greater than -5
    property: fn(n) { n > -5 },
  )
  |> should.equal(Error(-5))
}

// int_uniform_inclusive
//
//

pub fn int_uniform_range__test() {
  let run_result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform_inclusive(-10, 10),
      property: fn(n) { -5 <= n && n <= 5 },
    )

  case run_result {
    // One of either glexer or glance is broken with Error(-6) here, so use the 
    // guard for now.
    Error(n) if n == -6 || n == 6 -> True
    _ -> False
  }
  |> should.be_true
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn positive_int_uniform_range_not_including_zero__shrinks_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform_inclusive(5, 10),
      property: fn(n) { 7 <= n && n <= 8 },
    )

  result
  |> should.equal(Error(5))
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn negative_int_uniform_range_not_including_zero__shrinks_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.int_uniform_inclusive(-10, -5),
      property: fn(n) { -8 >= n && n >= -7 },
    )

  result
  |> should.equal(Error(-5))
}
