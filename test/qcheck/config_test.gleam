import qcheck

pub fn negative_seeds_are_ok__test() {
  use n <- qcheck.run(
    qcheck.default_config() |> qcheck.with_seed(qcheck.seed(-1)),
    qcheck.int_small_strictly_positive(),
  )

  n > 0
}

pub fn negative_test_counts_are_replaced_with_a_good_value__test() {
  let assert Error(_) = {
    use <- qcheck.rescue
    use n <- qcheck.run(
      qcheck.default_config() |> qcheck.with_test_count(-1),
      qcheck.int_small_strictly_positive(),
    )

    // This will only fail if the negative test count is replaced with a
    // reasonable value.
    // 
    // If the test count was left as negative or 0, then this property would
    // never be executed.
    n <= 0
  }
}
