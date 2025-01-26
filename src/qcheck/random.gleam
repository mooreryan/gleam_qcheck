//// Vendored or altered versions of functions from prng's `random` module.
//// 
//// Mostly these functions replace float generation with integer generation
//// where possible.  This provides a large increase in downstream generator
//// speed.
//// 
//// This module is considered private.  Breaking changes may occur at any time 
//// without a major version increase.
//// 

import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/pair
import prng/random as prng_random

pub fn weighted(
  first: #(Int, a),
  others: List(#(Int, a)),
) -> prng_random.Generator(a) {
  let normalise = fn(pair: #(Int, a)) { int.absolute_value(pair.first(pair)) }
  let total = normalise(first) + int.sum(list.map(others, normalise))
  prng_random.map(prng_random.int(0, total - 1), get_by_weight(first, others, _))
}

pub fn uniform(first: a, others: List(a)) -> prng_random.Generator(a) {
  weighted(#(1, first), list.map(others, pair.new(1, _)))
}

pub fn choose(one: a, or other: a) -> prng_random.Generator(a) {
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

pub fn try_weighted(
  options: List(#(Int, a)),
) -> Result(prng_random.Generator(a), Nil) {
  case options {
    [first, ..rest] -> Ok(weighted(first, rest))
    [] -> Error(Nil)
  }
}

pub fn try_uniform(options: List(a)) -> Result(prng_random.Generator(a), Nil) {
  case options {
    [first, ..rest] -> Ok(uniform(first, rest))
    [] -> Error(Nil)
  }
}
