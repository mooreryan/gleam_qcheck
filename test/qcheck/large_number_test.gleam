import qcheck

// See https://github.com/mooreryan/gleam_qcheck/issues/7
pub fn large_numbers__test() {
  use _ <- qcheck.given(qcheck.int_uniform_inclusive(0, 100_000_000))
  True
}
