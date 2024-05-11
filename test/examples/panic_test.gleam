import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/qtest/test_error_message

pub fn gleeunit_fail__test() {
  let generator = {
    use n <- generator.map(generator.small_positive_or_zero_int())
    n + 10
  }

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qtest.run_panic(
      config: qtest_config.default(),
      generator: generator,
      property: fn(n) { should.be_true(n <= 13 || n >= 25) },
    )
  }

  test_error_message.shrunk_value(msg)
  |> should.equal("14")
}

pub fn assert_fail__test() {
  let generator = {
    use n <- generator.map(generator.small_positive_or_zero_int())
    n + 10
  }

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qtest.run_panic(
      config: qtest_config.default(),
      generator: generator,
      property: fn(n) {
        let assert True = {
          n <= 13 || n >= 25
        }
      },
    )
  }

  test_error_message.shrunk_value(msg)
  |> should.equal("14")
}
