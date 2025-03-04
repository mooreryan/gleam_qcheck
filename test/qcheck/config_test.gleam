import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn negative_seeds_are_ok__test() {
  use n <- qcheck.run(
    qcheck.default_config() |> qcheck.with_seed(qcheck.seed(-1)),
    qcheck.small_strictly_positive_int(),
  )

  should.be_true(n > 0)
}

pub fn negative_test_counts_are_replaced_with_a_good_value__test() {
  let assert Error(_) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.default_config() |> qcheck.with_test_count(-1),
      qcheck.small_strictly_positive_int(),
    )

    // This will only fail if the negative test count is replaced with a
    // reasonable value.
    //
    // If the test count was left as negative or 0, then this property would
    // never be executed.
    should.be_true(n <= 0)
  }
}

pub fn zero_test_counts_are_replaced_with_a_good_value__test() {
  let assert Error(_) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.default_config() |> qcheck.with_test_count(0),
      qcheck.small_strictly_positive_int(),
    )

    should.be_true(n <= 0)
  }
}

pub fn config_replaces_bad_args_with_good_ones__test() {
  let assert Error(_) = {
    use <- test_error_message.rescue
    use n <- qcheck.run(
      qcheck.config(test_count: -1, max_retries: -1, seed: qcheck.seed(-1)),
      qcheck.small_strictly_positive_int(),
    )

    should.be_true(n <= 0)
  }
}
