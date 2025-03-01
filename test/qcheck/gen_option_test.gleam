import gleam/option.{None, Some}
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn option__test() {
  use int_option <- qcheck.run(
    qcheck.default_config(),
    qcheck.small_non_negative_int()
      |> qcheck.option_from,
  )
  case int_option {
    Some(n) -> should.equal(n + 1, 1 + n)
    None -> should.be_true(True)
  }
}

pub fn option__failures_shrink_ok__test() {
  let run = fn(property) {
    qcheck.run(
      qcheck.default_config(),
      qcheck.small_non_negative_int() |> qcheck.option_from,
      property,
    )
  }

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- run
    case n {
      Some(n) -> should.equal(n, n + 1)
      None -> should.be_true(True)
    }
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(Some(0)))

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- run
    case n {
      Some(n) -> should.be_true(n <= 5 || n == n + 1)
      None -> should.be_true(True)
    }
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(Some(6)))

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- run
    case n {
      Some(n) -> should.equal(n, n)
      None -> should.be_true(False)
    }
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(None))
}

pub fn option_sometimes_generates_none__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use value <- qcheck.run(
      qcheck.default_config(),
      qcheck.small_non_negative_int() |> qcheck.option_from,
    )
    // All values are `Some` (False)
    should.be_true(option.is_some(value))
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(None))
}
