import gleeunit/should
import qcheck

pub fn int_addition_commutativity__test() {
  use n <- qcheck.given(qcheck.small_non_negative_int())
  should.equal(n + 1, 1 + n)
}
// Uncomment this function when you need to generate the error message for the basic example in the README.
//
// pub fn int_addition_commutativity__failures_shrink_to_zero__test() {
//   use n <- qcheck.given(qcheck.small_non_negative_int())
//   should.not_equal(n + 1, 1 + n)
// }
