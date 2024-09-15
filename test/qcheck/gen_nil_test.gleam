import qcheck

pub fn nil_only_generates_nil__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.nil(),
    property: fn(nil) {
      case nil {
        Nil -> True
      }
    },
  )
}
