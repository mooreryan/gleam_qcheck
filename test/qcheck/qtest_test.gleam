import gleam/int
import gleam/option.{None, Some}
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

pub fn passing_test() {
  qtest.run(
    config: qtest_config.default()
      |> qtest_config.with_test_count(1000),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n + 1 == 1 + n },
  )
  |> should.equal(Ok(Nil))
}

pub fn failing_qtest_shrinks_to_zero__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n + 1 != 1 + n },
  )
  |> should.equal(Error(0))
}

pub fn failing_qtest_shrinks_to_small_value__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n == 0 || n > 1 },
  )
  |> should.equal(Error(1))
}

pub fn map_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(int.to_float),
    property: fn(n) { n == 0.0 || n >. 1.0 },
  )
  |> should.equal(Error(1.0))
}

pub fn small_strictly_positive_int_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    property: fn(n) { n > 0 },
  )
  |> should.equal(Ok(Nil))
}

pub fn small_strictly_positive_int_failing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    property: fn(n) { n > 1 },
  )
  |> should.equal(Error(1))
}

pub fn int_uniform_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n == n + 0 },
  )
  |> should.equal(Ok(Nil))
}

pub fn int_uniform_failing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n < 55_555 },
  )
  |> should.equal(Error(55_555))
}

pub fn negative_numbers_will_still_shrink_towards_zero_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n > -2 },
  )
  |> should.equal(Error(-2))
}

pub fn run_result_passing_test() {
  qtest.run_result(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) {
      // Integer->String->Integer round tripping.
      n
      |> int.to_string
      |> int.parse
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn run_result_failing_test() {
  qtest.run_result(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: int.divide(1, _),
  )
  |> should.equal(Error(0))
}

type MyInt {
  MyInt(Int)
}

fn my_int_to_int(my_int) {
  let MyInt(n) = my_int
  n
}

pub fn custom_type_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(MyInt),
    property: fn(my_int) {
      let MyInt(n) = my_int
      n == my_int_to_int(my_int)
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn custom_type_failing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(MyInt),
    property: fn(my_int) {
      let MyInt(n) = my_int
      n < 10
    },
  )
  |> should.equal(Error(MyInt(10)))
}

pub fn option_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.option,
    property: fn(maybe_int) {
      case maybe_int {
        Some(n) -> n + 1 == 1 + n
        None -> True
      }
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn option_sometimes_generates_none_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.option,
    property: option.is_some,
  )
  |> should.equal(Error(None))
}
