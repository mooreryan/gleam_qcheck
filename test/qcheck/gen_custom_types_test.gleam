import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn custom_type_passing_test() {
  use my_int <- qcheck.run(
    qcheck.default_config(),
    qcheck.small_non_negative_int() |> qcheck.map(MyInt),
  )
  let MyInt(n) = my_int
  should.equal(my_int_to_int(my_int), n)
}

pub fn custom_type_failing_test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use my_int <- qcheck.run(
      qcheck.default_config(),
      qcheck.small_non_negative_int() |> qcheck.map(MyInt),
    )
    let MyInt(n) = my_int
    should.be_true(n < 10)
  }
  test_error_message.shrunk_value(msg)
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
  use v <- qcheck.run(
    qcheck.default_config(),
    qcheck.small_non_negative_int() |> qcheck.map(even_odd),
  )
  case v {
    First(n) -> should.equal(n % 2, 0)
    Second(n) -> should.equal(n % 2, 1)
  }
}

pub fn either_failing_test() {
  let run = fn(property) {
    qcheck.run(
      qcheck.default_config(),
      qcheck.small_non_negative_int() |> qcheck.map(even_odd),
      property,
    )
  }

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use v <- run
    case v {
      First(n) -> should.equal(n % 2, 1)
      Second(n) -> should.equal(n % 2, 0)
    }
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(First(0)))

  // The n == 0 will prevent the First(0) from being a shrink that fails
  // the property.
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use v <- run
    case v {
      First(n) -> should.be_true(n == 0 || n % 2 == 1)
      Second(n) -> should.be_true(n % 2 == 0)
    }
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(Second(1)))

  // The n == 1 will prevent the Second(1) from being a shrink that
  // fails the property.
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use v <- run
    case v {
      First(n) -> should.be_true(n == 0 || n % 2 == 1)
      Second(n) -> should.be_true(n == 1 || n % 2 == 0)
    }
  }
  test_error_message.shrunk_value(msg)
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
