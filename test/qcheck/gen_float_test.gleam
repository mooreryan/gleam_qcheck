import gleam/float
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn float__failures_shrink_towards_zero__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.float(),
      property: fn(_) { False },
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(0.0))
}

// float_uniform_inclusive
//
//

pub fn float_uniform_range__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.float_uniform_inclusive(-10.0, 10.0),
      property: fn(x) { -5.0 <=. x && x <=. 5.0 },
    )
  }

  let assert Ok(x) =
    test_error_message.test_error_message_shrunk_value(msg)
    |> float.parse

  should.be_true(-6.0 <=. x && x <=. -5.0 || 5.0 <=. x && x <=. 6.0)
}

// This test ensures that you aren't shrinking to zero if the float range doesn't
// include zero.
pub fn positive_float_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.float_uniform_inclusive(5.0, 10.0),
      property: fn(x) { 7.0 <=. x && x <=. 8.0 },
    )
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(5.0))
}

// This test ensures that you aren't shrinking to zero if the float range doesn't
// include zero.
pub fn negative_float_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.float_uniform_inclusive(-10.0, -5.0),
      property: fn(x) { -8.0 >=. x && x >=. -7.0 },
    )
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(-5.0))
}

pub fn float_uniform_inclusive__high_less_than_low_ok__test() {
  use n <- qcheck.given(qcheck.float_uniform_inclusive(10.0, -10.0))

  -10.0 <=. n && n <=. 10.0
}
