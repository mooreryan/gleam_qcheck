import gleam/int
import gleam/option.{None, Some}
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

pub fn passing_test() {
  qtest.run(
    config: qtest_config.default()
      |> qtest_config.with_test_count(1000),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n + 1 == 1 + n },
  )
  |> should.equal(Ok(Nil))
}

pub fn failing_qtest_shrinks_to_zero__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n + 1 != 1 + n },
  )
  |> should.equal(Error(0))
}

pub fn failing_qtest_shrinks_to_small_value__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: fn(n) { n == 0 || n > 1 },
  )
  |> should.equal(Error(1))
}

pub fn map_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(int.to_float),
    property: fn(n) { n == 0.0 || n >. 1.0 },
  )
  |> should.equal(Error(1.0))
}

pub fn small_strictly_positive_int_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    property: fn(n) { n > 0 },
  )
  |> should.equal(Ok(Nil))
}

pub fn small_strictly_positive_int_failing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_strictly_positive_int(),
    property: fn(n) { n > 1 },
  )
  |> should.equal(Error(1))
}

pub fn int_uniform_passing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n == n + 0 },
  )
  |> should.equal(Ok(Nil))
}

pub fn int_uniform_failing_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n < 55_555 },
  )
  |> should.equal(Error(55_555))
}

pub fn negative_numbers_will_still_shrink_towards_zero_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) { n > -2 },
  )
  |> should.equal(Error(-2))
}

pub fn run_result_passing_test() {
  qtest.run_result(
    config: qtest_config.default(),
    generator: generator.int_uniform(),
    property: fn(n) {
      // Integer->String->Integer round tripping.
      n
      |> int.to_string
      |> int.parse
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn run_result_failing_test() {
  qtest.run_result(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int(),
    property: int.divide(1, _),
  )
  |> should.equal(Error(0))
}

// qtest with custom types
//
//

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

pub fn option_passing_test() {
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

pub fn option_failing_test() {
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

pub fn option_sometimes_generates_none_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.option,
    property: option.is_some,
  )
  |> should.equal(Error(None))
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
