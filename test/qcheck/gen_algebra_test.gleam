import gleam/int
import gleam/result
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

// map
// 
//

pub fn map__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.small_positive_or_zero_int()
      |> generator.map(int.to_float),
    property: fn(n) { n == 0.0 || n >. 1.0 },
  )
  |> should.equal(Error(1.0))
}

// bind
//
// The following tests exercise the shrinking behavior when using bind to 
// generate custom types.
//
//

type Either(a, b) {
  First(a)
  Second(b)
}

pub fn shrinking_works_with_bind_and_custom_types_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform()
      |> generator.bind(fn(n) {
      // n >= 0 here will set the shrinker starting on the `First` case, as that
      // is what 0 will become.
      case n >= 0 {
        True ->
          generator.int_uniform_inclusive(10, 19)
          |> generator.map(First)
        False ->
          generator.int_uniform_inclusive(90, 99)
          |> generator.map(int.to_float)
          |> generator.map(Second)
      }
    }),
    property: fn(either) {
      // Adding the two extra failing cases for First and Second to test the 
      // shrinking.
      case either {
        First(15) -> False
        First(14) -> False
        First(_) -> True
        Second(95.0) -> False
        Second(94.0) -> False
        Second(_) -> True
      }
    },
  )
  |> should.equal(Error(First(14)))
}

pub fn shrinking_works_with_bind_and_custom_types_2_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform()
      |> generator.bind(fn(n) {
      // n > 0 here will set the shrinker starting on the `Second` case, as that
      // is what 0 will become.
      case n > 0 {
        True ->
          generator.int_uniform_inclusive(10, 19)
          |> generator.map(First)
        False ->
          generator.int_uniform_inclusive(90, 99)
          |> generator.map(int.to_float)
          |> generator.map(Second)
      }
    }),
    property: fn(either) {
      case either {
        First(15) -> False
        First(14) -> False
        First(_) -> True
        Second(95.0) -> False
        Second(94.0) -> False
        Second(_) -> True
      }
    },
  )
  |> should.equal(Error(Second(94.0)))
}

pub fn shrinking_works_with_bind_and_custom_types_3_test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.int_uniform()
      |> generator.bind(fn(n) {
      case n > 0 {
        True ->
          generator.int_uniform_inclusive(10, 19)
          |> generator.map(First)
        False ->
          generator.int_uniform_inclusive(90, 99)
          |> generator.map(int.to_float)
          |> generator.map(Second)
      }
    }),
    // None of the `Second` shrinks will trigger a failure.
    property: fn(either) {
      case either {
        First(15) -> False
        First(14) -> False
        _ -> True
      }
    },
  )
  |> should.equal(Error(First(14)))
}

// apply
// 
// 

fn curry3(f) {
  fn(a) { fn(b) { fn(c) { f(a, b, c) } } }
}

fn tuple3() {
  fn(a, b, c) { #(a, b, c) }
  |> curry3
}

pub fn apply__test() {
  let generator =
    generator.int_uniform_inclusive(-5, 5)
    |> generator.map(tuple3())
    |> generator.apply(generator.int_uniform_inclusive(-10, 10), _)
    |> generator.apply(generator.int_uniform_inclusive(-100, 100), _)

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 5
      let b_prop = -10 <= b && b <= 10
      let c_prop = -100 <= c && c <= 100

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn shrinking_works_with_apply__test() {
  let generator =
    generator.int_uniform_inclusive(-5, 5)
    |> generator.map(tuple3())
    |> generator.apply(generator.int_uniform_inclusive(-10, 10), _)
    |> generator.apply(generator.int_uniform_inclusive(-100, 100), _)

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 3
      let b_prop = -10 <= b && b <= 10
      let c_prop = -100 <= c && c <= 100

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Error(#(4, 0, 0)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -3 <= a && a <= 5
      let b_prop = -10 <= b && b <= 10
      let c_prop = -100 <= c && c <= 100

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Error(#(-4, 0, 0)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 5
      let b_prop = -10 <= b && b <= 5
      let c_prop = -100 <= c && c <= 100

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Error(#(0, 6, 0)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 5
      let b_prop = -5 <= b && b <= 10
      let c_prop = -100 <= c && c <= 100

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Error(#(0, -6, 0)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 5
      let b_prop = -10 <= b && b <= 10
      let c_prop = -100 <= c && c <= 50

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Error(#(0, 0, 51)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 5
      let b_prop = -10 <= b && b <= 10
      let c_prop = -50 <= c && c <= 100

      a_prop && b_prop && c_prop
    },
  )
  |> should.equal(Error(#(0, 0, -51)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -5 <= a && a <= 3
      let b_prop = -10 <= b && b <= 5
      let c_prop = -100 <= c && c <= 50

      a_prop || b_prop || c_prop
    },
  )
  |> should.equal(Error(#(4, 6, 51)))

  qtest.run(
    config: qtest_config.default(),
    generator: generator,
    property: fn(ns) {
      let #(a, b, c) = ns
      let a_prop = -3 <= a && a <= 3
      let b_prop = -5 <= b && b <= 5
      let c_prop = -50 <= c && c <= 50

      a_prop || b_prop || c_prop
    },
  )
  // The way this is set up, the failing values will either be positve or 
  // negative for each "slot", so we must map the absolute value.
  |> result.map_error(fn(e) {
    case e {
      #(a, b, c) -> #(
        int.absolute_value(a),
        int.absolute_value(b),
        int.absolute_value(c),
      )
    }
  })
  |> should.equal(Error(#(4, 6, 51)))
}
