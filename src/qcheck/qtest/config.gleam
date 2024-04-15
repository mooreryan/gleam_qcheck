import prng/seed.{type Seed}

pub type Config {
  Config(test_count: Int, max_retries: Int, random_seed: Seed)
}

pub fn default() -> Config {
  Config(test_count: 10_000, max_retries: 1, random_seed: seed.random())
}

pub fn with_test_count(config, test_count) {
  Config(..config, test_count: test_count)
}

pub fn with_max_retries(config, max_retries) {
  Config(..config, max_retries: max_retries)
}

pub fn with_random_seed(config, random_seed) {
  Config(..config, random_seed: random_seed)
}
