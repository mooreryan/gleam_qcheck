import gleam/int
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

pub fn run_result__propery_ok_means_pass__test() {
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

pub fn run_result__property_error_means_fail__test() {
  qtest.run_result(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: int.divide(1, _),
  )
  |> should.equal(Error(0))
}
