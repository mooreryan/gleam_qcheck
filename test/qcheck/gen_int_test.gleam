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
