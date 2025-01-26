// These tests are adapted from tests for the `random` module in the `prng`
// package.

import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/string
import gleam/yielder
import gleeunit/should
import qcheck/random

pub fn qcheck_random_weighted_never_returns_value_with_zero_weight_test() {
  let languages = random.weighted(#(1, "Gleam"), [#(0, "TypeScript")])
  do_test(for_all: languages, that: fn(language) { language == "Gleam" })
}

pub fn uniform_generates_values_from_the_given_list_test() {
  let examples = random.uniform(1, [2, 3])
  do_test(for_all: examples, that: fn(n) { n == 1 || n == 2 || n == 3 })
}

pub fn choose_behaves_the_same_as_uniform_test() {
  let gen1 = random.choose(1, 2)
  let gen2 = random.uniform(1, [2])
  behaves_the_same(gen1, gen2)
}

pub fn uniform_behaves_like_weighted_when_all_weights_are_equal_test() {
  let gen1 = random.uniform("a", ["b", "c"])
  let gen2 = random.weighted(#(2, "a"), [#(2, "b"), #(2, "c")])

  assert_similar_distributions(gen1, gen2, string.compare)
}

pub fn weighted_with_different_but_proportional_weights_test() {
  let gen1 = random.weighted(#(2, "a"), [#(2, "b"), #(2, "c")])
  let gen2 = random.weighted(#(1, "a"), [#(1, "b"), #(1, "c")])

  assert_similar_distributions(gen1, gen2, string.compare)
}

// MARK: utils

fn do_test(
  for_all generator: random.Generator(a),
  that property: fn(a) -> Bool,
) -> Nil {
  let number_of_samples = 1000
  let samples =
    random.to_random_yielder(generator)
    |> yielder.take(number_of_samples)
    |> yielder.to_list

  // The yielder should be infinite, so we _must_ always have 1000 samples
  list.length(samples)
  |> should.equal(number_of_samples)

  // Check that all generated values respect the given property
  list.all(samples, property)
  |> should.equal(True)
}

fn behaves_the_same(gen1: random.Generator(a), gen2: random.Generator(a)) -> Nil {
  let seed =
    random.int(random.min_int, random.max_int)
    |> random.map(random.seed)
    |> random.random_sample

  let samples1 =
    random.to_yielder(gen1, seed)
    |> yielder.take(1000)
    |> yielder.to_list
  let samples2 =
    random.to_yielder(gen2, seed)
    |> yielder.take(1000)
    |> yielder.to_list

  should.equal(samples1, samples2)
}

/// Check that two distributions are similar.
/// 
fn assert_similar_distributions(
  gen1: random.Generator(a),
  gen2: random.Generator(a),
  compare: fn(a, a) -> Order,
) -> Nil {
  let seed =
    random.int(random.min_int, random.max_int)
    |> random.map(random.seed)
    |> random.random_sample

  let samples1 =
    random.to_yielder(gen1, seed)
    |> yielder.take(100_000)
    |> yielder.to_list
  let samples2 =
    random.to_yielder(gen2, seed)
    |> yielder.take(100_000)
    |> yielder.to_list

  let proportions1 = samples1 |> frequencies |> proportions
  let proportions2 = samples2 |> frequencies |> proportions

  proportions_are_loosely_equal(proportions1, proportions2, compare)
  |> should.be_true
}

/// Count the number of times each element appears in a list.
/// 
fn frequencies(lst: List(a)) -> Dict(a, Int) {
  list.fold(lst, dict.new(), fn(counts, item) {
    dict.upsert(counts, item, increment)
  })
}

/// Given a dict of frequencies, return a dict of proportions.
/// 
fn proportions(frequencies: Dict(a, Int)) -> Dict(a, Float) {
  let total = dict.values(frequencies) |> list.fold(0, int.add) |> int.to_float

  dict.map_values(frequencies, fn(_item, count) { int.to_float(count) /. total })
}

/// Given a dict of proportions, sort it by the keys.
/// 
fn sort_proportions(
  proportions: Dict(a, b),
  compare_elem: fn(a, a) -> Order,
) -> List(#(a, b)) {
  proportions
  |> dict.to_list
  |> list.sort(fn(a, b) {
    let #(elem_a, _) = a
    let #(elem_b, _) = b
    compare_elem(elem_a, elem_b)
  })
}

/// Given two dicts of proportions, check that they are similar.
/// 
/// The proportions are considered similar if the keys are the same and the
/// proportions are within 1% of each other.
/// 
fn proportions_are_loosely_equal(
  proportions1: Dict(a, Float),
  proportions2: Dict(a, Float),
  compare_elem: fn(a, a) -> Order,
) -> Bool {
  case
    list.strict_zip(
      sort_proportions(proportions1, compare_elem),
      sort_proportions(proportions2, compare_elem),
    )
  {
    Ok(zipped) ->
      zipped
      |> list.all(fn(tup) {
        let #(#(elem_a, proportion_a), #(elem_b, proportion_b)) = tup

        elem_a == elem_b
        && float.loosely_equals(proportion_a, proportion_b, tolerating: 0.01)
      })

    // The lengths are different, so fail.
    Error(Nil) -> False
  }
}

/// Increment a value in a dict.
fn increment(x: Option(Int)) -> Int {
  case x {
    Some(n) -> n + 1
    None -> 1
  }
}
