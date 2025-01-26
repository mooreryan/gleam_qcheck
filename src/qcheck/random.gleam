//// Vendored or altered versions of functions from prng's `random` module.
//// 
//// Mostly these functions replace float generation with integer generation
//// where possible.  This provides a large increase in downstream generator
//// speed.
//// 
//// This module is considered private.  Breaking changes may occur at any time 
//// without a major version increase.
//// 

// TODO: need to harmonize this API with the rest of the qcheck api (labels, names, etc.)

import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/pair
import gleam/yielder.{type Yielder}
import prng/random as prng_random
import prng/seed as prng_seed

// MARK: Seeds

/// An opaque type representing a seed value used to initialize random generators.
/// 
pub opaque type Seed {
  Seed(seed: prng_seed.Seed)
}

/// `seed(n) creates a new seed from the given integer, `n`.
///
/// ### Example
/// 
/// Use a specific seed for the `Config`.
/// 
/// ```
/// let config = 
///   qcheck.default_config() 
///   |> qcheck.with_seed(qcheck.seed(124))
/// ```
/// 
pub fn seed(n: Int) -> Seed {
  prng_seed.new(n) |> Seed
}

/// `seed_random()` creates a new randomly-generated seed.  You can use it when
/// you don't care about having specifically reproducible results.
///
/// ### Example
/// 
/// Use a random seed for the `Config`.
/// 
/// ```
/// let config = 
///   qcheck.default_config() 
///   |> qcheck.with_seed(qcheck.seed_random())
/// ```
/// 
pub fn seed_random() -> Seed {
  prng_seed.random() |> Seed
}

/// Attempting to generate values below this limit will not lead to good random results.
/// 
pub const min_int = prng_random.min_int

/// Attempting to generate values below this limit will not lead to good random results.
/// 
pub const max_int = prng_random.max_int

pub opaque type Generator(a) {
  Generator(generator: prng_random.Generator(a))
}

pub fn step(generator: Generator(a), seed: Seed) -> #(a, Seed) {
  let #(a, seed) = prng_random.step(generator.generator, seed.seed)
  #(a, Seed(seed))
}

pub fn int(from: Int, to: Int) -> Generator(Int) {
  prng_random.int(from, to) |> Generator
}

pub fn float(from: Float, to: Float) -> Generator(Float) {
  prng_random.float(from, to) |> Generator
}

pub fn float_weighted(
  first: #(Float, a),
  others: List(#(Float, a)),
) -> Generator(a) {
  prng_random.weighted(first, others) |> Generator
}

pub fn weighted(first: #(Int, a), others: List(#(Int, a))) -> Generator(a) {
  let normalise = fn(pair: #(Int, a)) { int.absolute_value(pair.first(pair)) }
  let total = normalise(first) + int.sum(list.map(others, normalise))

  prng_random.map(prng_random.int(0, total - 1), get_by_weight(first, others, _))
  |> Generator
}

pub fn uniform(first: a, others: List(a)) -> Generator(a) {
  weighted(#(1, first), list.map(others, pair.new(1, _)))
}

pub fn choose(one: a, or other: a) -> Generator(a) {
  uniform(one, [other])
}

fn get_by_weight(first: #(Int, a), others: List(#(Int, a)), countdown: Int) -> a {
  let #(weight, value) = first
  case others {
    [] -> value
    [second, ..rest] -> {
      let positive_weight = int.absolute_value(weight)
      case int.compare(countdown, positive_weight) {
        Lt -> value
        Gt | Eq -> get_by_weight(second, rest, countdown - positive_weight)
      }
    }
  }
}

// TODO: need a bind to match our API (and probably need a then in our API to
// better fit in with stdlib?)
pub fn then(
  generator: Generator(a),
  do generator_from: fn(a) -> Generator(b),
) -> Generator(b) {
  prng_random.then(generator.generator, fn(a) {
    // We need to unwrap and wrap the values of this function since we're
    // "hiding" the prng.random implementation.
    let generator = generator_from(a)
    generator.generator
  })
  |> Generator
}

pub fn map(generator: Generator(a), with fun: fn(a) -> b) -> Generator(b) {
  prng_random.map(generator.generator, fun) |> Generator
}

pub fn to_random_yielder(from generator: Generator(a)) -> Yielder(a) {
  prng_random.to_random_yielder(generator.generator)
}

pub fn to_yielder(generator: Generator(a), seed: Seed) -> Yielder(a) {
  prng_random.to_yielder(generator.generator, seed.seed)
}

pub fn random_sample(generator: Generator(a)) -> a {
  prng_random.random_sample(generator.generator)
}

pub fn sample(from generator: Generator(a), with seed: Seed) -> a {
  prng_random.sample(generator.generator, seed.seed)
}

pub fn constant(value: a) -> Generator(a) {
  prng_random.constant(value) |> Generator
}
