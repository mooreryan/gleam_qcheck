import gleam/int
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
