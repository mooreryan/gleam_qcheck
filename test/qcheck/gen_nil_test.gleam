import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

pub fn nil_only_generates_nil__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.nil(),
    property: fn(nil) {
      case nil {
        Nil -> True
      }
    },
  )
}
