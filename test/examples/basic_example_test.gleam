import gleeunit/should
import qcheck

pub fn small_positive_or_zero_int__test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())
  should.equal(n + 1, 1 + n)
}
// Uncomment this function when you need to generate the error message for the basic example in the README.
//
// pub fn small_positive_or_zero_int__failures_shrink_to_zero__test() {
//   use n <- qcheck.given(qcheck.small_positive_or_zero_int())
//   n + 1 != 1 + n
// }
