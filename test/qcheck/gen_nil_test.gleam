import gleeunit/should
import qcheck

pub fn nil_only_generates_nil__test() {
  use nil <- qcheck.run(qcheck.default_config(), qcheck.nil())
  case nil {
    Nil -> should.be_true(True)
  }
}
