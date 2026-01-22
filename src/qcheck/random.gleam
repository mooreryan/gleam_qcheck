//// Random
////
//// The random module provides basic random value generators that can be used
//// to define Generators.
////
//// They are mostly inteded for internal use or "advanced" manual construction
//// of generators.  In typical usage, you will probably not need to interact
//// with these functions much, if at all.  As such, they are currently mostly
//// undocumented.
////

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
  prng_random.new_seed(n) |> Seed
}

/// `random_seed()` creates a new randomly-generated seed.  You can use it when
/// you don't care about having specifically reproducible results.
///
/// ### Example
///
/// Use a random seed for the `Config`.
///
/// ```
/// let config =
///   qcheck.default_config()
///   |> qcheck.with_seed(qcheck.random_seed())
/// ```
///
pub fn random_seed() -> Seed {
  int.random(max_int) |> seed()
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

pub fn int(from from: Int, to to: Int) -> Generator(Int) {
  prng_random.int(from, to) |> Generator
}

pub fn float(from from: Float, to to: Float) -> Generator(Float) {
  prng_random.float(from, to) |> Generator
}

/// Like `weighted` but uses `Floats` to specify the weights.
///
/// Generally you should prefer `weighted` as it is faster.
///
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

pub fn choose(one: a, other: a) -> Generator(a) {
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

pub fn bind(generator: Generator(a), f: fn(a) -> Generator(b)) -> Generator(b) {
  prng_random.then(generator.generator, fn(a) {
    // We need to unwrap and wrap the values of this function since we're
    // "hiding" the prng.random implementation.
    let generator = f(a)
    generator.generator
  })
  |> Generator
}

/// `then` is an alias for `bind`.
///
pub fn then(generator: Generator(a), f: fn(a) -> Generator(b)) -> Generator(b) {
  bind(generator, f)
}

pub fn map(generator: Generator(a), fun: fn(a) -> b) -> Generator(b) {
  prng_random.map(generator.generator, fun) |> Generator
}

pub fn to_random_yielder(generator: Generator(a)) -> Yielder(a) {
  to_yielder(generator, random_seed())
}

pub fn to_yielder(generator: Generator(a), seed: Seed) -> Yielder(a) {
  yielder.unfold(seed, fn(current_seed) {
    let #(value, next_seed) = step(generator, current_seed)
    yielder.Next(value, next_seed)
  })
}

pub fn random_sample(generator: Generator(a)) -> a {
  sample(generator, random_seed())
}

pub fn sample(generator: Generator(a), seed: Seed) -> a {
  step(generator, seed).0
}

pub fn constant(value: a) -> Generator(a) {
  prng_random.constant(value) |> Generator
}
