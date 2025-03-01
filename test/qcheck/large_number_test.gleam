import gleeunit/should
import qcheck

// See https://github.com/mooreryan/gleam_qcheck/issues/7
pub fn large_numbers__test() {
  use _ <- qcheck.given(qcheck.bounded_int(0, 100_000_000))
  should.be_true(True)
}
