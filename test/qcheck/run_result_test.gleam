import gleam/int
import gleam/string
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/qtest/test_error_message as err

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
}

pub fn run_result__property_error_means_fail__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run_result(
      config: qtest_config.default(),
      generator: generator.small_positive_or_zero_int(),
      property: int.divide(1, _),
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(0))
}
