import gleam/int
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

// small_non_negative_int
//
//

pub fn small_non_negative_int__test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())
  should.equal(n + 1, 1 + n)
}

pub fn small_non_negative_int__failures_shrink_to_zero__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.given(qcheck.small_non_negative_int())
    should.not_equal(n + 1, 1 + n)
  }

  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(0))
}

pub fn small_non_negative_int__failures_shrink_to_smaller_values__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.default_config(),
      qcheck.small_non_negative_int(),
    )
    should.be_true(n == 0 || n > 1)
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(1))
}

// small_strictly_positive_int
//
//

pub fn small_strictly_positive_int__test() {
  use n <- qcheck.run(
    qcheck.default_config(),
    qcheck.small_strictly_positive_int(),
  )
  should.be_true(n > 0)
}

pub fn small_strictly_positive_int__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.default_config(),
      qcheck.small_strictly_positive_int(),
    )
    should.be_true(n > 1)
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(1))

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.default_config(),
      qcheck.small_strictly_positive_int(),
    )
    should.be_true(n == 1 || n > 2)
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(2))
}

// uniform_int
//
//

pub fn uniform_int__test() {
  use n <- qcheck.run(qcheck.default_config(), qcheck.uniform_int())
  should.equal(n + 1, 1 + n)
}

pub fn uniform_int__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(qcheck.default_config(), qcheck.uniform_int())
    should.be_true(n < 55_555)
  }

  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(55_555))
}

pub fn uniform_int__negative_numbers_shrink_towards_zero__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(qcheck.default_config(), qcheck.uniform_int())
    should.be_true(n > -5)
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(-5))
}

// bounded_int
//
//

pub fn uniform_int_range__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(qcheck.default_config(), qcheck.bounded_int(-10, 10))
    should.be_true(-5 <= n && n <= 5)
  }

  let assert Ok(n) =
    test_error_message.shrunk_value(msg)
    |> int.parse

  should.be_true(n == -6 || n == 6)
  // case run_result {
  //   // One of either glexer or glance is broken with Error(-6) here, so use the
  //   // guard for now.
  //   Error(n) if n == -6 || n == 6 -> True
  //   _ -> False
  // }
  // |> should.be_true
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn positive_uniform_int_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(qcheck.default_config(), qcheck.bounded_int(5, 10))
    should.be_true(7 <= n && n <= 8)
  }

  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(5))
}

// This test ensures that you aren't shrinking to zero if the int range doesn't
// include zero.
pub fn negative_uniform_int_range_not_including_zero__shrinks_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(qcheck.default_config(), qcheck.bounded_int(-10, -5))
    should.be_true(-8 >= n && n >= -7)
  }

  test_error_message.shrunk_value(msg)
  |> should.equal(string.inspect(-5))
}

pub fn bounded_int__high_less_than_low_ok__test() {
  use n <- qcheck.given(qcheck.bounded_int(10, -10))
  should.be_true(-10 <= n && n <= 10)
}
