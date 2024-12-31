import gleam/string
import gleeunit/should
import qcheck

pub fn custom_type_passing_test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.int_small_positive_or_zero() |> qcheck.map(MyInt),
    property: fn(my_int) {
      let MyInt(n) = my_int
      n == my_int_to_int(my_int)
    },
  )
}

pub fn custom_type_failing_test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_positive_or_zero() |> qcheck.map(MyInt),
      property: fn(my_int) {
        let MyInt(n) = my_int
        n < 10
      },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(MyInt(10)))
}

type Either(a, b) {
  First(a)
  Second(b)
}

fn even_odd(n: Int) -> Either(Int, Int) {
  case n % 2 == 0 {
    True -> First(n)
    False -> Second(n)
  }
}

pub fn either_passing_test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.int_small_positive_or_zero() |> qcheck.map(even_odd),
    property: fn(v) {
      case v {
        First(n) -> n % 2 == 0
        Second(n) -> n % 2 == 1
      }
    },
  )
}

pub fn either_failing_test() {
  let run = fn(property) {
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.int_small_positive_or_zero() |> qcheck.map(even_odd),
      property: property,
    )
  }

  let assert Error(msg) = {
    use <- qcheck.rescue
    run(fn(v) {
      case v {
        First(n) -> n % 2 == 1
        Second(n) -> n % 2 == 0
      }
    })
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(First(0)))

  // The n == 0 will prevent the First(0) from being a shrink that fails
  // the property.
  let assert Error(msg) = {
    use <- qcheck.rescue
    run(fn(v) {
      case v {
        First(n) -> n == 0 || n % 2 == 1
        Second(n) -> n % 2 == 0
      }
    })
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(Second(1)))

  // The n == 1 will prevent the Second(1) from being a shrink that
  // fails the property.
  let assert Error(msg) = {
    use <- qcheck.rescue
    run(fn(v) {
      case v {
        First(n) -> n == 0 || n % 2 == 1
        Second(n) -> n == 1 || n % 2 == 0
      }
    })
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect(First(2)))
}

// utils
//
//

type MyInt {
  MyInt(Int)
}

fn my_int_to_int(my_int) {
  let MyInt(n) = my_int
  n
}
