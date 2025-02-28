import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn run_result__property_error_means_fail__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.given_assertion(qcheck.small_non_negative_int())
    n |> should.equal(n + 1)
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(0))
}
