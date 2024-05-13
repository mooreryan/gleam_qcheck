import gleam/option.{None, Some}
import gleam/string
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/qtest/test_error_message as err

pub fn option__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.option,
    property: fn(int_option) {
      case int_option {
        Some(n) -> n + 1 == 1 + n
        None -> True
      }
    },
  )
}

pub fn option__failures_shrink_ok__test() {
  let run = fn(property) {
    qtest.run(
      config: qtest_config.default(),
      generator: generator.small_positive_or_zero_int()
        |> generator.option,
      property: property,
    )
  }

  let assert Error(msg) = {
    use <- err.rescue
    run(fn(n) {
      case n {
        Some(n) -> n == n + 1
        None -> True
      }
    })
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(Some(0)))

  let assert Error(msg) = {
    use <- err.rescue
    run(fn(n) {
      case n {
        Some(n) -> n <= 5 || n == n + 1
        None -> True
      }
    })
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(Some(6)))

  let assert Error(msg) = {
    use <- err.rescue
    run(fn(n) {
      case n {
        Some(n) -> n == n
        None -> False
      }
    })
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(None))
}

pub fn option_sometimes_generates_none__test() {
  let assert Error(msg) = {
    use <- err.rescue
    qtest.run(
      config: qtest_config.default(),
      generator: generator.small_positive_or_zero_int()
        |> generator.option,
      // All values are `Some` (False)
      property: option.is_some,
    )
  }
  err.shrunk_value(msg)
  |> should.equal(string.inspect(None))
}
