import gleeunit/should
import qcheck

// This test just ensures that we create `UtfCodepoint`s without raising
// exceptions:  once Gleam returns us a value if type `UtfCodepoint`, we know
// that it is valid.
pub fn utf_codepoint__smoke_test() {
  use _ <- qcheck.given(qcheck.uniform_codepoint())
  should.be_true(True)
}
