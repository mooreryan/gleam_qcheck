import gleam/option.{None, Some}
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

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
  |> should.equal(Ok(Nil))
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

  run(fn(n) {
    case n {
      Some(n) -> n == n + 1
      None -> True
    }
  })
  |> should.equal(Error(Some(0)))

  run(fn(n) {
    case n {
      Some(n) -> n <= 5 || n == n + 1
      None -> True
    }
  })
  |> should.equal(Error(Some(6)))

  run(fn(n) {
    case n {
      Some(n) -> n == n
      None -> False
    }
  })
  |> should.equal(Error(None))
}

pub fn option_sometimes_generates_none__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.option,
    // All values are `Some` (False)
    property: option.is_some,
  )
  |> should.equal(Error(None))
}
