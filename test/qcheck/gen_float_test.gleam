import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

pub fn float__failures_shrink_towards_zero__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.float(),
    property: fn(_) { False },
  )
  |> should.equal(Error(0.0))
}

// float_uniform_inclusive
//
//

pub fn float_uniform_range__test() {
  let run_result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float_uniform_inclusive(-10.0, 10.0),
      property: fn(x) { -5.0 <=. x && x <=. 5.0 },
    )

  case run_result {
    // It should shrink to a number close to -5 but less, OR close to 5 but more.
    Error(x)
      if -6.0 <=. x && x <=. -5.0 || 5.0 <=. x && x <=. 6.0
    -> True
    _ -> False
  }
  |> should.be_true
}

// This test ensures that you aren't shrinking to zero if the float range doesn't
// include zero.
pub fn positive_float_uniform_range_not_including_zero__shrinks_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float_uniform_inclusive(5.0, 10.0),
      property: fn(x) { 7.0 <=. x && x <=. 8.0 },
    )

  result
  |> should.equal(Error(5.0))
}

// This test ensures that you aren't shrinking to zero if the float range doesn't
// include zero.
pub fn negative_float_uniform_range_not_including_zero__shrinks_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.float_uniform_inclusive(-10.0, -5.0),
      property: fn(x) { -8.0 >=. x && x >=. -7.0 },
    )

  result
  |> should.equal(Error(-5.0))
}
