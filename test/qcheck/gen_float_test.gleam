import gleam/float
import gleam/string
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/qtest/test_error_message as err

pub fn float__failures_shrink_towards_zero__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float(),
      property: fn(_) { False },
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(0.0))
}

// float_uniform_inclusive
//
//

pub fn float_uniform_range__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float_uniform_inclusive(-10.0, 10.0),
      property: fn(x) { -5.0 <=. x && x <=. 5.0 },
    )
  }

  let assert Ok(x) =
    err.shrunk_value(msg)
    |> float.parse

  should.be_true(-6.0 <=. x && x <=. -5.0 || 5.0 <=. x && x <=. 6.0)
}

// This test ensures that you aren't shrinking to zero if the float range doesn't
// include zero.
pub fn positive_float_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float_uniform_inclusive(5.0, 10.0),
      property: fn(x) { 7.0 <=. x && x <=. 8.0 },
    )
  }

  err.shrunk_value(msg)
  |> should.equal(string.inspect(5.0))
}

// This test ensures that you aren't shrinking to zero if the float range doesn't
// include zero.
pub fn negative_float_uniform_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float_uniform_inclusive(-10.0, -5.0),
      property: fn(x) { -8.0 >=. x && x >=. -7.0 },
    )
  }

  err.shrunk_value(msg)
  |> should.equal(string.inspect(-5.0))
}
