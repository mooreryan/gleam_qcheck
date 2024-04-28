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
