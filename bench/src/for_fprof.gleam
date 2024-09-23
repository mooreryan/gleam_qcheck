import prng/seed
import qcheck

pub fn main() {
  qcheck.run(
    config: qcheck.default_config()
      |> qcheck.with_test_count(2500)
      |> qcheck.with_random_seed(seed.new(1234)),
    generator: qcheck.string(),
    property: fn(_) { True },
  )
}
