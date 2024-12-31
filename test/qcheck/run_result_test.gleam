import gleam/int
import gleam/string
import gleeunit/should
import qcheck

pub fn run_result__propery_ok_means_pass__test() {
  qcheck.run_result(
    config: qcheck.default_config(),
    generator: qcheck.int_uniform(),
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
    use <- qcheck.rescue
    qcheck.run_result(
      config: qcheck.default_config(),
      generator: qcheck.int_small_positive_or_zero(),
      property: int.divide(1, _),
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(0))
}
