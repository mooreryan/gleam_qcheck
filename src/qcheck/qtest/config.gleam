//// This module provides the configuration for the property-based testing.

import prng/seed.{type Seed}

/// Configuration for the property-based testing.
/// 
/// - `test_count`: The number of tests to run for each property.
/// - `max_retries`: The number of times to retry the tested property while 
///   shrinking.
/// - `random_seed`: The seed for the random generator.
pub type Config {
  Config(test_count: Int, max_retries: Int, random_seed: Seed)
}

/// `default()` returns the default configuration for the property-based testing.
pub fn default() -> Config {
  Config(test_count: 10_000, max_retries: 1, random_seed: seed.random())
}

/// `with_test_count()` returns a new configuration with the given test count.
pub fn with_test_count(config, test_count) {
  Config(..config, test_count: test_count)
}

/// `with_max_retries()` returns a new configuration with the given max retries.
pub fn with_max_retries(config, max_retries) {
  Config(..config, max_retries: max_retries)
}

/// `with_random_seed()` returns a new configuration with the given random seed.
pub fn with_random_seed(config, random_seed) {
  Config(..config, random_seed: random_seed)
}
