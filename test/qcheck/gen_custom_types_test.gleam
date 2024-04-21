import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

type MyInt {
  MyInt(Int)
}

fn my_int_to_int(my_int) {
  let MyInt(n) = my_int
  n
}

pub fn custom_type_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(MyInt),
    property: fn(my_int) {
      let MyInt(n) = my_int
      n == my_int_to_int(my_int)
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn custom_type_failing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(MyInt),
    property: fn(my_int) {
      let MyInt(n) = my_int
      n < 10
    },
  )
  |> should.equal(Error(MyInt(10)))
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
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(even_odd),
    property: fn(v) {
      case v {
        First(n) -> n % 2 == 0
        Second(n) -> n % 2 == 1
      }
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn either_failing_test() {
  let run = fn(property) {
    qtest.run(
      config: qtest_config.default(),
      generator: generator.small_positive_or_zero_int()
        |> generator.map(even_odd),
      property: property,
    )
  }

  run(fn(v) {
    case v {
      First(n) -> n % 2 == 1
      Second(n) -> n % 2 == 0
    }
  })
  |> should.equal(Error(First(0)))

  // The n == 0 will prevent the First(0) from being a shrink that fails
  // the property.
  run(fn(v) {
    case v {
      First(n) -> n == 0 || n % 2 == 1
      Second(n) -> n % 2 == 0
    }
  })
  |> should.equal(Error(Second(1)))

  // The n == 1 will prevent the Second(1) from being a shrink that
  // fails the property.
  run(fn(v) {
    case v {
      First(n) -> n == 0 || n % 2 == 1
      Second(n) -> n == 1 || n % 2 == 0
    }
  })
  |> should.equal(Error(First(2)))
}
