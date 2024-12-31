import qcheck

pub fn int_small_positive_or_zero__test() {
  use n <- qcheck.given(qcheck.int_small_positive_or_zero())
  n + 1 == 1 + n
}
// Uncomment this function when you need to generate the error message for the basic example in the README.
//
// pub fn int_small_positive_or_zero__failures_shrink_to_zero__test() {
//   use n <- qcheck.given(qcheck.int_small_positive_or_zero())
//   n + 1 != 1 + n
// }
