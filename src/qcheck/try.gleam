import exception

pub type Try(a) {
  NoPanic(a)
  Panic(exception.Exception)
}

pub fn try(f: fn() -> a) -> Try(a) {
  case exception.rescue(fn() { f() }) {
    Ok(y) -> NoPanic(y)
    Error(exn) -> Panic(exn)
  }
}
