import gleam/option.{None, Some}
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn option__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.int_small_positive_or_zero()
      |> qcheck.option,
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
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_positive_or_zero()
        |> qcheck.option,
      property: property,
    )
  }

  let assert Error(msg) = {
    use <- test_error_message.rescue
    run(fn(n) {
      case n {
        Some(n) -> n == n + 1
        None -> True
      }
    })
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(Some(0)))

  let assert Error(msg) = {
    use <- test_error_message.rescue
    run(fn(n) {
      case n {
        Some(n) -> n <= 5 || n == n + 1
        None -> True
      }
    })
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(Some(6)))

  let assert Error(msg) = {
    use <- test_error_message.rescue
    run(fn(n) {
      case n {
        Some(n) -> n == n
        None -> False
      }
    })
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(None))
}

pub fn option_sometimes_generates_none__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_positive_or_zero()
        |> qcheck.option,
      // All values are `Some` (False)
      property: option.is_some,
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(None))
}
