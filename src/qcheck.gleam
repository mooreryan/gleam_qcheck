//// QuickCheck-inspired property-based testing with integrated shrinking
//// 
//// 
//// ## Overview
//// 
//// Rather than specifying test cases manually, you describe the invariants
//// that values of a given type must satisfy ("properties"). Then, generators
//// generate lots of values (test cases) on which the properties are checked.
//// Finally, if a value is found for which a given property does not hold, that
//// value is "shrunk" in order to find an nice, informative counter-example 
//// that is presented to you.
//// 
//// This module has functions for running and configuring property tests as
//// well as generating random values (with shrinking) to drive those tests.
////
//// For usage examples, see the project README.
//// 
//// 
//// ## Running tests
//// 
//// - [given](#given)
//// - [given_result](#given_result)
//// - [run](#run)
//// - [run_result](#run_result)
//// 
//// 
//// ## Configuring test runs
//// 
//// - The [Config](#Config) type
//// - [default_config](#default_config)
//// - [with_test_count](#with_test_count)
//// - [with_max_retries](#with_max_retries)
//// - [with_random_seed](#with_random_seed)
//// 
//// 
//// ## Generators
//// 
//// - The [Generator](#Generator) type
//// 
//// Here is a list of generator functions grouped by category.
//// 
//// ### Combinators
//// 
//// - [return](#return)
//// - [map](#map)
//// - [bind](#bind)
//// - [apply](#apply)
//// - [map2](#map2)
//// - [map3](#map3)
//// - [map4](#map4)
//// - [map5](#map5)
//// - [map6](#map6)
//// - [tuple2](#tuple2)
//// - [tuple3](#tuple3)
//// - [tuple4](#tuple4)
//// - [tuple5](#tuple5)
//// - [tuple6](#tuple6)
//// - [from_generators](#from_generators)
//// - [from_weighted_generators](#from_weighted_generators)
//// - [from_float_weighted_generators](#from_weighted_generators)
//// 
//// ### Ints
//// 
////  - [int_uniform](#int_uniform)
////  - [int_uniform_inclusive](#int_uniform_inclusive)
////  - [small_positive_or_zero_int](#small_positive_or_zero_int)
////  - [small_strictly_positive_int](#small_strictly_positive_int)
//// 
//// ### Floats
//// 
////  - [float](#float)
////  - [float_uniform_inclusive](#float_uniform_inclusive)
//// 
//// ### Characters
//// 
////  - [char](#char)
////  - [char_uniform_inclusive](#char_uniform_inclusive)
////  - [char_uppercase](#char_uppercase)
////  - [char_lowercase](#char_lowercase)
////  - [char_digit](#char_digit)
////  - [char_print_uniform](#char_print_uniform)
////  - [char_uniform](#char_uniform)
////  - [char_alpha](#char_alpha)
////  - [char_alpha_numeric](#char_alpha_numeric)
////  - [char_from_list](#char_from_list)
////  - [char_whitespace](#char_whitespace)
////  - [char_print](#char_print)
//// 
//// ### Strings
//// 
////  - [string](#string)
////  - [string_from](#string_from)
////  - [string_non_empty](#string_non_empty)
////  - [string_with_length](#string_with_length)
////  - [string_with_length_from](#string_with_length_from)
////  - [string_non_empty_from](#string_non_empty_from)
////  - [string_generic](#string_generic)
//// 
//// ### Lists
//// 
////  - [list_generic](#list_generic)
//// 
//// ### Dicts
//// 
//// - [dict_generic](#dict_generic)
////
//// ### Sets
//// 
////  - [set_generic](#set_generic)
////
//// ### Other
//// 
//// - [bool](#bool)
//// - [nil](#nil)
//// - [option](#option)
//// 
//// ## Trees
//// 
//// There are functions for dealing with the [Tree](#Tree) type directly, but 
//// they are low-level and you should not need to use them much. 
//// 
//// - The [Tree](#Tree) type
//// - [make_primitive_tree](#make_primitive_tree)
//// - [return_tree](#return_tree)
//// - [map_tree](#map_tree)
//// - [map2_tree](#map2_tree)
//// - [bind_tree](#bind_tree)
//// - [apply_tree](#apply_tree)
//// - [sequence_list](#sequence_list)
//// - [option_tree](#option_tree)
//// - [tree_to_string](#tree_to_string)
//// - [tree_to_string_](#tree_to_string_)
//// 
//// ## Shrinking
//// 
//// There are some public functions for dealing with shrinks and shrinking.
//// Similar to the Tree functions, you often won't need to use these directly.
////
//// - [shrink_atomic](#shrink_atomic)
//// - [shrink_int_towards](#shrink_int_towards)
//// - [shrink_int_towards_zero](#shrink_int_towards_zero)
//// - [shrink_float_towards](#shrink_float_towards)
//// - [shrink_float_towards_zero](#shrink_float_towards_zero)
////
//// 
//// ## Notes
//// 
//// - If something is marked as being “unspecified”, do not depend on it, as it
////   may change at any time without a major version bump. This mainly applies 
////   to the various `*_to_string` functions.
//// - `TestError`, `TestErrorMessage`, and association functions will likely 
////   become private as they are mainly internal machinery for displaying 
////   errors.
//// - `failwith`, `try`, and `rescue` will also likely become private as they 
////   deal with internal property test running machinery.
//// 
//// 

import exception
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/set
import gleam/string
import gleam/string_builder.{type StringBuilder}
import prng/random
import prng/seed.{type Seed}
import qcheck/prng_random

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Running tests 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// `run(config, generator, property)` runs the `property` function against some
/// test cases generated by the `generator` function according to the specified 
/// `config`
/// 
/// The `run` function returns `Nil` if the property holds (i.e., return 
/// `True` for all test cases), or panics if the property does not 
/// hold for some test case `a` (i.e., returns `False` or `panic`s).
/// 
/// 
pub fn run(
  config config: Config,
  generator generator: Generator(a),
  property property: fn(a) -> Bool,
) -> Nil {
  do_run(config, generator, property, 0)
}

/// A specialized version of `run` that uses the default configuration.
/// 
/// 
pub fn given(
  generator generator: Generator(a),
  property property: fn(a) -> Bool,
) -> Nil {
  run(default_config(), generator, property)
}

/// `run_result(config, generator, property)` is like `run` but the property
/// function returns a `Result` instead of a `Bool`.
/// 
///
pub fn run_result(
  config config: Config,
  generator generator: Generator(a),
  property property: fn(a) -> Result(b, error),
) -> Nil {
  do_run_result(config, generator, property, 0)
}

/// A specialized version of `run_result` that uses the default configuration.
/// 
/// 
pub fn given_result(
  generator generator: Generator(a),
  property property: fn(a) -> Result(b, error),
) -> Nil {
  run_result(default_config(), generator, property)
}

fn do_run(
  config: Config,
  generator: Generator(a),
  property: fn(a) -> Bool,
  i: Int,
) -> Nil {
  case i >= config.test_count {
    True -> Nil
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(config.random_seed)
      let Tree(value, _shrinks) = tree

      case try(fn() { property(value) }) {
        NoPanic(True) ->
          do_run(
            config
              |> with_random_seed(seed),
            generator,
            property,
            i + 1,
          )
        NoPanic(False) -> {
          let #(shrunk_value, shrink_steps) =
            shrink(tree, property, run_property_max_retries: config.max_retries)

          failwith(
            original_value: value,
            shrunk_value: shrunk_value,
            shrink_steps: shrink_steps,
            error_msg: "property was False",
          )
        }
        Panic(exn) -> {
          let #(shrunk_value, shrink_steps) =
            shrink(tree, property, run_property_max_retries: config.max_retries)

          failwith(
            original_value: value,
            shrunk_value: shrunk_value,
            shrink_steps: shrink_steps,
            error_msg: string.inspect(exn),
          )
        }
      }
    }
  }
}

fn do_run_result(
  config: Config,
  generator: Generator(a),
  property: fn(a) -> Result(b, error),
  i: Int,
) -> Nil {
  case i >= config.test_count {
    True -> Nil
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(config.random_seed)
      let Tree(value, _shrinks) = tree

      case try(fn() { property(value) }) {
        NoPanic(Ok(_)) ->
          do_run_result(
            config
              |> with_random_seed(seed),
            generator,
            property,
            i + 1,
          )
        NoPanic(Error(e)) -> {
          let #(shrunk_value, shrink_steps) =
            shrink_result(
              tree,
              property,
              run_property_max_retries: config.max_retries,
            )

          failwith(
            original_value: value,
            shrunk_value: shrunk_value,
            shrink_steps: shrink_steps,
            error_msg: string.inspect(e),
          )
        }
        Panic(exn) -> {
          let #(shrunk_value, shrink_steps) =
            shrink_result(
              tree,
              property,
              run_property_max_retries: config.max_retries,
            )

          failwith(
            original_value: value,
            shrunk_value: shrunk_value,
            shrink_steps: shrink_steps,
            error_msg: string.inspect(exn),
          )
        }
      }
    }
  }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Test config 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
pub fn default_config() -> Config {
  Config(test_count: 1000, max_retries: 1, random_seed: seed.random())
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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Trees
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pub type Tree(a) {
  Tree(a, Iterator(Tree(a)))
}

// `shrink` should probably be `shrink_steps` or `make_shrink_steps`
pub fn make_primitive_tree(
  root x: a,
  shrink shrink: fn(a) -> Iterator(a),
) -> Tree(a) {
  let shrink_trees =
    shrink(x)
    |> iterator.map(make_primitive_tree(_, shrink))

  Tree(x, shrink_trees)
}

pub fn map_tree(tree: Tree(a), f: fn(a) -> b) -> Tree(b) {
  let Tree(x, xs) = tree
  let y = f(x)
  let ys = iterator.map(xs, fn(smaller_x) { map_tree(smaller_x, f) })

  Tree(y, ys)
}

pub fn bind_tree(tree: Tree(a), f: fn(a) -> Tree(b)) -> Tree(b) {
  let Tree(x, xs) = tree

  let Tree(y, ys_of_x) = f(x)

  let ys_of_xs = iterator.map(xs, fn(smaller_x) { bind_tree(smaller_x, f) })

  let ys = iterator.append(ys_of_xs, ys_of_x)

  Tree(y, ys)
}

pub fn apply_tree(f: Tree(fn(a) -> b), x: Tree(a)) -> Tree(b) {
  let Tree(x0, xs) = x
  let Tree(f0, fs) = f

  let y = f0(x0)

  let ys =
    iterator.append(
      iterator.map(fs, fn(f_) { apply_tree(f_, x) }),
      iterator.map(xs, fn(x_) { apply_tree(f, x_) }),
    )

  Tree(y, ys)
}

pub fn return_tree(x: a) -> Tree(a) {
  Tree(x, iterator.empty())
}

pub fn map2_tree(f: fn(a, b) -> c, a: Tree(a), b: Tree(b)) -> Tree(c) {
  f
  |> curry2
  |> return_tree
  |> apply_tree(a)
  |> apply_tree(b)
}

/// `sequence_list(list_of_trees)` sequsences a list of trees into a tree of lists.
/// 
pub fn sequence_list(l: List(Tree(a))) -> Tree(List(a)) {
  case l {
    [] -> return_tree([])
    [hd, ..tl] -> {
      map2_tree(list_cons, hd, sequence_list(tl))
    }
  }
}

fn iterator_cons(element: a, iterator: fn() -> Iterator(a)) -> Iterator(a) {
  iterator.yield(element, iterator)
}

pub fn option_tree(tree: Tree(a)) -> Tree(Option(a)) {
  let Tree(x, xs) = tree

  // Shrink trees will all have None as a value.
  let shrinks =
    iterator_cons(return_tree(None), fn() { iterator.map(xs, option_tree) })

  Tree(Some(x), shrinks)
}

// Debugging trees

/// `tree_to_string(tree, element_to_string)` converts a tree into an unspecified string representation.
/// 
/// - `element_to_string`: a function that converts individual elements of the tree to strings.
/// 
pub fn tree_to_string(tree: Tree(a), a_to_string: fn(a) -> String) -> String {
  do_tree_to_string(tree, a_to_string, level: 0, max_level: 99_999_999, acc: [])
}

/// Like `tree_to_string` but with a configurable `max_depth`.
/// 
pub fn tree_to_string_(
  tree: Tree(a),
  a_to_string: fn(a) -> String,
  max_depth max_depth: Int,
) -> String {
  do_tree_to_string(tree, a_to_string, level: 0, max_level: max_depth, acc: [])
}

fn do_tree_to_string(
  tree: Tree(a),
  a_to_string a_to_string: fn(a) -> String,
  level level: Int,
  max_level max_level: Int,
  acc acc: List(String),
) -> String {
  case tree {
    Tree(root, children) -> {
      let padding = string.repeat("-", times: level)

      let children = case level > max_level {
        False ->
          children
          |> iterator.map(fn(tree) {
            do_tree_to_string(tree, a_to_string, level + 1, max_level, acc)
          })
          |> iterator.to_list
          |> string.join("")

        True ->
          children
          |> iterator.map(fn(_) { "" })
          |> iterator.to_list
          |> string.join("")
      }

      let root = padding <> a_to_string(root)

      root <> "\n" <> children
    }
  }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Shrinking
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fn float_half_difference(x: Float, y: Float) -> Float {
  { x /. 2.0 } -. { y /. 2.0 }
}

fn int_half_difference(x: Int, y: Int) -> Int {
  { x / 2 } - { y / 2 }
}

fn int_shrink_step(
  x x: Int,
  current_shrink current_shrink: Int,
) -> iterator.Step(Int, Int) {
  case x == current_shrink {
    True -> iterator.Done
    False -> {
      let half_difference = int_half_difference(x, current_shrink)

      case half_difference == 0 {
        True -> {
          iterator.Next(current_shrink, x)
        }
        False -> {
          iterator.Next(current_shrink, current_shrink + half_difference)
        }
      }
    }
  }
}

fn float_shrink_step(
  x x: Float,
  current_shrink current_shrink: Float,
) -> iterator.Step(Float, Float) {
  case x == current_shrink {
    True -> iterator.Done
    False -> {
      let half_difference = float_half_difference(x, current_shrink)

      case half_difference == 0.0 {
        True -> {
          iterator.Next(current_shrink, x)
        }
        False -> {
          iterator.Next(current_shrink, current_shrink +. half_difference)
        }
      }
    }
  }
}

pub fn shrink_int_towards(
  destination destination: Int,
) -> fn(Int) -> iterator.Iterator(Int) {
  fn(x) {
    iterator.unfold(destination, fn(current_shrink) {
      int_shrink_step(x: x, current_shrink: current_shrink)
    })
  }
}

pub fn shrink_float_towards(
  destination destination: Float,
) -> fn(Float) -> iterator.Iterator(Float) {
  fn(x) {
    iterator.unfold(destination, fn(current_shrink) {
      float_shrink_step(x: x, current_shrink: current_shrink)
    })
    // (Arbitrarily) Limit to the first 15 elements as dividing a `Float` by 2
    // doesn't converge quickly towards the destination.
    |> iterator.take(15)
  }
}

pub fn shrink_int_towards_zero() -> fn(Int) -> iterator.Iterator(Int) {
  shrink_int_towards(destination: 0)
}

pub fn shrink_float_towards_zero() -> fn(Float) -> iterator.Iterator(Float) {
  shrink_float_towards(destination: 0.0)
}

type RunPropertyResult {
  RunPropertyOk
  RunPropertyFail
}

// See QCheck2.run_law for why we bother with this seemingly pointless thing.
fn do_run_property(
  property: fn(a) -> Bool,
  value: a,
  max_retries: Int,
  i: Int,
) -> RunPropertyResult {
  case i < max_retries {
    True -> {
      case try(fn() { property(value) }) {
        NoPanic(True) -> do_run_property(property, value, max_retries, i + 1)
        NoPanic(False) | Panic(_) -> RunPropertyFail
      }
    }
    False -> RunPropertyOk
  }
}

// See QCheck2.run_law for why we bother with this seemingly pointless thing.
fn do_run_property_result(
  property: fn(a) -> Result(b, error),
  value: a,
  max_retries: Int,
  i: Int,
) -> RunPropertyResult {
  case i < max_retries {
    True -> {
      case try(fn() { property(value) }) {
        NoPanic(Ok(_)) ->
          do_run_property_result(property, value, max_retries, i + 1)
        NoPanic(Error(_)) | Panic(_) -> RunPropertyFail
      }
    }
    False -> RunPropertyOk
  }
}

fn run_property(
  property: fn(a) -> Bool,
  value: a,
  max_retries: Int,
) -> RunPropertyResult {
  do_run_property(property, value, max_retries, 0)
}

fn run_property_result(
  property: fn(a) -> Result(b, error),
  value: a,
  max_retries: Int,
) -> RunPropertyResult {
  do_run_property_result(property, value, max_retries, 0)
}

fn shrink(
  tree: Tree(a),
  property: fn(a) -> Bool,
  run_property_max_retries run_property_max_retries: Int,
) {
  do_shrink(tree, property, run_property_max_retries, 0)
}

fn do_shrink(
  tree: Tree(a),
  property: fn(a) -> Bool,
  run_property_max_retries run_property_max_retries: Int,
  shrink_count shrink_count: Int,
) -> #(a, Int) {
  let Tree(original_failing_value, shrinks) = tree

  let result =
    shrinks
    |> filter_map(fn(tree) {
      let Tree(value, _) = tree

      case run_property(property, value, run_property_max_retries) {
        RunPropertyOk -> None
        RunPropertyFail -> Some(tree)
      }
    })
    |> iterator.first

  case result {
    // Error means no head here.
    Error(Nil) -> #(original_failing_value, shrink_count)
    // We have a head, that means we had a fail in one of the shrinks.
    Ok(next_tree) ->
      do_shrink(next_tree, property, run_property_max_retries, shrink_count + 1)
  }
}

fn shrink_result(
  tree: Tree(a),
  property: fn(a) -> Result(b, error),
  run_property_max_retries run_property_max_retries: Int,
) {
  do_shrink_result(tree, property, run_property_max_retries, 0)
}

fn do_shrink_result(
  tree: Tree(a),
  property: fn(a) -> Result(b, error),
  run_property_max_retries run_property_max_retries: Int,
  shrink_count shrink_count: Int,
) -> #(a, Int) {
  let Tree(original_failing_value, shrinks) = tree

  let result =
    shrinks
    |> filter_map(fn(tree) {
      let Tree(value, _) = tree

      case run_property_result(property, value, run_property_max_retries) {
        RunPropertyOk -> None
        RunPropertyFail -> Some(tree)
      }
    })
    |> iterator.first

  case result {
    // Error means no head here.
    Error(Nil) -> #(original_failing_value, shrink_count)
    // We have a head, that means we had a fail in one of the shrinks.
    Ok(next_tree) ->
      do_shrink_result(
        next_tree,
        property,
        run_property_max_retries,
        shrink_count + 1,
      )
  }
}

/// The `atomic` shrinker treats types as atomic, and never attempts to produce
/// smaller values.
pub fn shrink_atomic() -> fn(a) -> Iterator(a) {
  fn(_) { iterator.empty() }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Generators 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// `Generator(a)` is a random generator for values of type `a`.
/// 
/// *Note:* Because it exposes the prng `Seed` type, it is likely that this type 
/// will become opaque in the future.
/// 
pub type Generator(a) {
  Generator(fn(Seed) -> #(Tree(a), Seed))
}

/// `generate(gen, seed)` generates a value of type `a` and its shrinks using the generator `gen`.
/// 
/// You should not use this function directly. It is for internal use only.
/// 
pub fn generate_tree(generator: Generator(a), seed: Seed) -> #(Tree(a), Seed) {
  let Generator(generate) = generator

  generate(seed)
}

fn make_primitive_generator(
  random_generator random_generator: random.Generator(a),
  make_tree make_tree: fn(a) -> Tree(a),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(generated_value, next_seed) = random.step(random_generator, seed)

    #(make_tree(generated_value), next_seed)
  })
}

// MARK: Combinators

/// `return(a)` creates a generator that always returns `a` and does not shrink.
/// 
pub fn return(a) {
  Generator(fn(seed) { #(return_tree(a), seed) })
}

/// `map(generator, f)` transforms the generator `generator` by applying `f` to 
/// each generated value.  Shrinks as `generator` shrinks, but with `f` applied.
/// 
pub fn map(generator generator: Generator(a), f f: fn(a) -> b) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree = map_tree(tree, f)

    #(tree, seed)
  })
}

/// `bind(generator, f)` generates a value of type `a` with `generator`, then 
/// passes that value to `f`, which uses it to generate values of type `b`.
/// 
pub fn bind(
  generator generator: Generator(a),
  f f: fn(a) -> Generator(b),
) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree =
      bind_tree(tree, fn(x) {
        let Generator(generate) = f(x)
        let #(tree, _seed) = generate(seed)
        tree
      })

    #(tree, seed)
  })
}

/// `apply(f, x)` applies a function generator, `f`, and an argument generator, 
/// `x`, into a result generator.
/// 
pub fn apply(
  f f: Generator(fn(a) -> b),
  generator x: Generator(a),
) -> Generator(b) {
  let Generator(f) = f
  let Generator(x) = x

  Generator(fn(seed) {
    let #(y_of_x, seed) = x(seed)
    let #(y_of_f, seed) = f(seed)
    let tree = apply_tree(y_of_f, y_of_x)

    #(tree, seed)
  })
}

/// `map2(f, g1, g2)` transforms two generators, `g1` and `g2`, by applying `f` 
/// to each pair of generated values.
/// 
pub fn map2(
  f f: fn(t1, t2) -> t3,
  g1 g1: Generator(t1),
  g2 g2: Generator(t2),
) -> Generator(t3) {
  f
  |> curry2
  |> return
  |> apply(g1)
  |> apply(g2)
}

/// `map3(f, g1, g2, g3)` transforms three generators, `g1`, `g2`, and `g3`, by
/// applying `f` to each triple of generated values.
/// 
pub fn map3(
  f f: fn(t1, t2, t3) -> t4,
  g1 g1: Generator(t1),
  g2 g2: Generator(t2),
  g3 g3: Generator(t3),
) -> Generator(t4) {
  f
  |> curry3
  |> return
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
}

/// `map4(f, g1, g2, g3, g4)` transforms four generators, `g1`, `g2`, `g3`, and
/// `g4`, by applying `f` to each quadruple of generated values.
/// 
pub fn map4(
  f f: fn(t1, t2, t3, t4) -> t5,
  g1 g1: Generator(t1),
  g2 g2: Generator(t2),
  g3 g3: Generator(t3),
  g4 g4: Generator(t4),
) -> Generator(t5) {
  f
  |> curry4
  |> return
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
  |> apply(g4)
}

/// `map5(f, g1, g2, g3, g4, g5)` transforms five generators, `g1`, `g2`, `g3`,
/// `g4`, and `g5`, by applying `f` to each quintuple of generated values.
/// 
pub fn map5(
  f f: fn(t1, t2, t3, t4, t5) -> t6,
  g1 g1: Generator(t1),
  g2 g2: Generator(t2),
  g3 g3: Generator(t3),
  g4 g4: Generator(t4),
  g5 g5: Generator(t5),
) -> Generator(t6) {
  f
  |> curry5
  |> return
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
  |> apply(g4)
  |> apply(g5)
}

/// `map6(f, g1, g2, g3, g4, g5, g6)` transforms six generators, `g1`, `g2`, `g3`,
/// `g4`, `g5`, and `g6`, by applying `f` to each sextuple of generated values.
/// 
pub fn map6(
  f f: fn(t1, t2, t3, t4, t5, t6) -> t7,
  g1 g1: Generator(t1),
  g2 g2: Generator(t2),
  g3 g3: Generator(t3),
  g4 g4: Generator(t4),
  g5 g5: Generator(t5),
  g6 g6: Generator(t6),
) -> Generator(t7) {
  f
  |> curry6
  |> return
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
  |> apply(g4)
  |> apply(g5)
  |> apply(g6)
}

/// `tuple2(g1, g2)` generates a tuple of two values, one each from generators 
/// `g1` and `g2`.
/// 
pub fn tuple2(g1: Generator(t1), g2: Generator(t2)) -> Generator(#(t1, t2)) {
  fn(t1, t2) { #(t1, t2) }
  |> map2(g1, g2)
}

/// `tuple3(g1, g2, g3)` generates a tuple of three values, one each from
/// generators `g1`, `g2`, and `g3`.
/// 
pub fn tuple3(
  g1: Generator(t1),
  g2: Generator(t2),
  g3: Generator(t3),
) -> Generator(#(t1, t2, t3)) {
  fn(t1, t2, t3) { #(t1, t2, t3) }
  |> map3(g1, g2, g3)
}

/// `tuple4(g1, g2, g3, g4)` generates a tuple of four values, one each from
/// generators `g1`, `g2`, `g3`, and `g4`.
/// 
pub fn tuple4(
  g1: Generator(t1),
  g2: Generator(t2),
  g3: Generator(t3),
  g4: Generator(t4),
) -> Generator(#(t1, t2, t3, t4)) {
  fn(t1, t2, t3, t4) { #(t1, t2, t3, t4) }
  |> map4(g1, g2, g3, g4)
}

/// `tuple5(g1, g2, g3, g4, g5)` generates a tuple of five values, one each from
/// generators `g1`, `g2`, `g3`, `g4`, and `g5`.
/// 
pub fn tuple5(
  g1: Generator(t1),
  g2: Generator(t2),
  g3: Generator(t3),
  g4: Generator(t4),
  g5: Generator(t5),
) -> Generator(#(t1, t2, t3, t4, t5)) {
  fn(t1, t2, t3, t4, t5) { #(t1, t2, t3, t4, t5) }
  |> map5(g1, g2, g3, g4, g5)
}

/// `tuple6(g1, g2, g3, g4, g5, g6)` generates a tuple of six values, one each 
/// from generators `g1`, `g2`, `g3`, `g4`, `g5`, and `g6`.
/// 
pub fn tuple6(
  g1: Generator(t1),
  g2: Generator(t2),
  g3: Generator(t3),
  g4: Generator(t4),
  g5: Generator(t5),
  g6: Generator(t6),
) -> Generator(#(t1, t2, t3, t4, t5, t6)) {
  fn(t1, t2, t3, t4, t5, t6) { #(t1, t2, t3, t4, t5, t6) }
  |> map6(g1, g2, g3, g4, g5, g6)
}

/// `from_generators(generators)` chooses a generator from a list of generators 
/// weighted uniformly, then chooses a value from that generator.
/// 
pub fn from_generators(generators: List(Generator(a))) -> Generator(a) {
  // TODO: better error message on empty list
  let assert [generator, ..generators] = generators

  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      prng_random.uniform(generator, generators) |> random.step(seed)

    generator(seed)
  })
}

/// `from_float_weighted_generators(generators)` chooses a generator from a list of generators
/// weighted by the given float weights, then chooses a value from that generator.
/// 
/// You should generally prefer `from_weighted_generators` as it is much faster.
/// 
pub fn from_float_weighted_generators(
  generators: List(#(Float, Generator(a))),
) -> Generator(a) {
  // TODO: better error message on empty list
  let assert [generator, ..generators] = generators

  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      random.weighted(generator, generators) |> random.step(seed)

    generator(seed)
  })
}

/// `from_float_generators(generators)` chooses a generator from a list of generators
/// weighted by the given integer weights, then chooses a value from that generator.
/// 
/// You should generally prefer this function over 
/// `from_float_weighted_generators` as this function is faster.
/// 
pub fn from_weighted_generators(
  generators: List(#(Int, Generator(a))),
) -> Generator(a) {
  // TODO: better error message on empty list
  let assert [generator, ..generators] = generators

  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      prng_random.weighted(generator, generators) |> random.step(seed)

    generator(seed)
  })
}

// MARK: Ints

// TODO: consider switching to base_quickcheck small int generator
/// `small_positive_or_zero_int()` generates small integers well suited for 
/// modeling the sizes of sized elements like lists or strings.
/// 
/// Smaller numbers are more likely than larger numbers.
/// 
/// Shrinks towards `0`.
/// 
pub fn small_positive_or_zero_int() -> Generator(Int) {
  make_primitive_generator(
    random_generator: random.int(0, 1)
      |> random.then(fn(x) {
        case x < 75 {
          True -> random.int(0, 10)
          False -> random.int(0, 100)
        }
      }),
    make_tree: fn(n) {
      make_primitive_tree(root: n, shrink: shrink_int_towards_zero())
    },
  )
}

/// `small_strictly_positive_int()` generates small integers strictly greater
/// than `0`.
/// 
pub fn small_strictly_positive_int() -> Generator(Int) {
  small_positive_or_zero_int()
  |> map(int.add(_, 1))
}

// The QCheck2 code does some fancy stuff to avoid generating ranges wider than
// `Int.max_int`. TODO: consider the implications for this code.
//
// TODO: QCheck2 code also has a parameter for the shrink origin.
// 
/// `int_uniform_inclusive(low, high)` generates integers uniformly distributed
/// between `low` and `high`, inclusive.
/// 
/// Shrinks towards `0`, but won't shrink outside of the range `[low, high]`.
pub fn int_uniform_inclusive(low low: Int, high high: Int) -> Generator(Int) {
  case high < low {
    True -> panic as "int_uniform_includive: high < low"
    False -> Nil
  }

  make_primitive_generator(
    random_generator: random.int(low, high),
    make_tree: fn(n) {
      let origin = pick_origin_within_range(low, high, goal: 0)

      make_primitive_tree(root: n, shrink: shrink_int_towards(origin))
    },
  )
}

// WARNING: doesn't hit the interesting cases very often.  Use something more like
//   qcheck2 or base_quickcheck.
/// `int_uniform()` generates uniformly distributed integers across a large 
/// range and shrinks towards `0`.
/// 
/// Note: this generator does not hit interesting or corner cases very often.
/// 
pub fn int_uniform() -> Generator(Int) {
  int_uniform_inclusive(random.min_int, random.max_int)
}

// MARK: Floats
//
// 

fn exp(x: Float) -> Float {
  let assert Ok(result) = float.power(2.71828, x)
  result
}

// Note: The base_quickcheck float generators are much fancier.  Should consider
// using their generation method.
//
/// `float()` generates floats with a bias towards smaller values and shrinks 
/// towards `0.0`.
/// 
pub fn float() -> Generator(Float) {
  Generator(fn(seed) {
    let #(x, seed) = random.float(0.0, 15.0) |> random.step(seed)
    let #(y, seed) = prng_random.choose(1.0, -1.0) |> random.step(seed)
    let #(z, seed) = prng_random.choose(1.0, -1.0) |> random.step(seed)

    // The QCheck2.Gen.float code has this double multiply in it. Actually not
    // sure about that.
    let generated_value = exp(x) *. y *. z

    let tree = make_primitive_tree(generated_value, shrink_float_towards_zero())

    #(tree, seed)
  })
}

pub fn float_uniform_inclusive(low: Float, high: Float) {
  case high <. low {
    True -> panic as "int_uniform_includive: high < low"
    False -> Nil
  }

  make_primitive_generator(
    random_generator: random.float(low, high),
    make_tree: fn(n) {
      let origin = pick_origin_within_range_float(low, high, goal: 0.0)

      make_primitive_tree(root: n, shrink: shrink_float_towards(origin))
    },
  )
}

// MARK: Characters

// Though gleam doesn't have a `Char` type, we need these one-character string
// generators so that we can shrink the `Generator(String)` type properly.

const char_min_value: Int = 0

// TODO: what is a reasonable value here?
const char_max_value: Int = 255

// TODO: why not take the "char" directly?
// For now, this is only used in setting up the string generators.
//
/// `char_uniform_inclusive(low, high)` generates "characters" uniformly
/// distributed between `low` and `high`, inclusive.  Here, "characters" are 
/// strings of a single codepoint.
/// 
/// *Note*: this function is slightly weird in that it takes the integer 
/// representation of the range of codepoints, not the strings themselves.  
/// This behavior will likely change.
/// 
/// These `char_*` functions are mainly used for setting up the string 
/// generators.
/// 
/// Shrinks towards `a` when possible, but won't go outside of the range.
/// 
pub fn char_uniform_inclusive(low low: Int, high high: Int) -> Generator(String) {
  let a = 97
  let origin = pick_origin_within_range(low, high, goal: a)
  let shrink = shrink_int_towards(origin)

  Generator(fn(seed) {
    let #(n, seed) =
      random.int(low, high)
      |> random.step(seed)

    let tree =
      make_primitive_tree(n, shrink)
      |> map_tree(int_to_char)

    #(tree, seed)
  })
}

/// `char_uppercase()` generates uppercase (ASCII) letters.
/// 
pub fn char_uppercase() -> Generator(String) {
  let a = char_to_int("A")
  let z = char_to_int("Z")

  char_uniform_inclusive(a, z)
}

/// `char_lowercase()` generates lowercase (ASCII) letters.
/// 
pub fn char_lowercase() -> Generator(String) {
  let a = char_to_int("a")
  let z = char_to_int("z")

  char_uniform_inclusive(a, z)
}

/// `char_digit()` generates digits from `0` to `9`, inclusive.
/// 
pub fn char_digit() -> Generator(String) {
  let zero = char_to_int("0")
  let nine = char_to_int("9")

  char_uniform_inclusive(zero, nine)
}

// TODO: name char_printable_uniform?
// Note: the shrink target for this will be `"a"`.
//
/// `char_print_uniform()` generates printable ASCII characters.
/// 
pub fn char_print_uniform() -> Generator(String) {
  let space = char_to_int(" ")
  let tilde = char_to_int("~")

  char_uniform_inclusive(space, tilde)
}

/// `char_uniform()` generates characters uniformly distributed across the 
/// default range.
/// 
pub fn char_uniform() -> Generator(String) {
  char_uniform_inclusive(char_min_value, char_max_value)
}

/// `char_alpha()` generates alphabetic (ASCII) characters.
/// 
pub fn char_alpha() -> Generator(String) {
  [char_uppercase(), char_lowercase()]
  |> from_generators
}

/// `char_alpha_numeric()` generates alphanumeric (ASCII) characters.
/// 
pub fn char_alpha_numeric() -> Generator(String) {
  [#(26, char_uppercase()), #(26, char_lowercase()), #(10, char_digit())]
  |> from_weighted_generators
}

/// `char_from_list(chars)` generates characters from the given list of
/// characters.
/// 
pub fn char_from_list(chars: List(String)) -> Generator(String) {
  let ints = list.map(chars, char_to_int)
  // TODO: assert that they are all single length chars
  let assert [hd, ..tl] = ints

  // Take the char with the minimum int representation as the shrink target.
  let shrink_target = list.fold(tl, hd, int.min)

  Generator(fn(seed) {
    let #(n, seed) = prng_random.uniform(hd, tl) |> random.step(seed)

    let tree =
      make_primitive_tree(n, shrink_int_towards(shrink_target))
      |> map_tree(int_to_char)

    #(tree, seed)
  })
}

fn all_char_list() {
  list.range(char_min_value, char_max_value)
}

// TODO: should probably account for other non-ascii whitespace chars
// This is from OCaml Stdlib.Char module
fn char_is_whitespace(c) {
  case c {
    // Horizontal tab
    9 -> True
    // Line feed
    10 -> True
    // Vertical tab
    11 -> True
    // Form feed 
    12 -> True
    // Carriage return
    13 -> True
    // Space
    32 -> True
    _ -> False
  }
}

/// `char_whitespace()` generates whitespace (ASCII) characters.
/// 
pub fn char_whitespace() -> Generator(String) {
  all_char_list()
  |> list.filter(char_is_whitespace)
  |> list.map(int_to_char)
  |> char_from_list
}

/// `char_print()` generates printable ASCII characters, with a bias towards
/// alphanumeric characters.
/// 
pub fn char_print() -> Generator(String) {
  // Numbers indicate percent chance of picking the generator.
  from_weighted_generators([
    #(381, char_uppercase()),
    #(381, char_lowercase()),
    #(147, char_digit()),
    #(91, char_print_uniform()),
  ])
}

/// `char()` generates characters with a bias towards printable ASCII 
/// characters, while still hitting some edge cases.
/// 
pub fn char() {
  // Numbers indicate percent chance of picking the generator.
  from_weighted_generators([
    #(340, char_uppercase()),
    #(340, char_lowercase()),
    #(131, char_digit()),
    #(81, char_print_uniform()),
    #(89, char_uniform()),
    #(09, return(int_to_char(char_min_value))),
    #(09, return(int_to_char(char_max_value))),
  ])
}

// MARK: Strings

fn do_gen_string(
  i: Int,
  string_builder: StringBuilder,
  char_gen: Generator(String),
  char_trees_rev: List(Tree(String)),
  seed: Seed,
) -> #(String, List(Tree(String)), Seed) {
  let Generator(gen_char_tree) = char_gen

  let #(char_tree, seed) = gen_char_tree(seed)

  case i <= 0 {
    True -> #(string_builder.to_string(string_builder), char_trees_rev, seed)
    False -> {
      let Tree(root, _) = char_tree

      do_gen_string(
        i - 1,
        string_builder |> string_builder.append(root),
        char_gen,
        [char_tree, ..char_trees_rev],
        seed,
      )
    }
  }
}

// This is the base string generator. The others are implemented in terms of
// this one.
//
/// `string_with_length_from(gen, length)` generates strings of the given 
/// `length` from the given generator.
/// 
pub fn string_with_length_from(
  generator: Generator(String),
  length: Int,
) -> Generator(String) {
  Generator(fn(seed) {
    let #(generated_string, char_trees_rev, seed) =
      do_gen_string(length, string_builder.new(), generator, [], seed)

    // TODO: Ideally this whole thing would be delayed until needed.
    let shrink = fn() {
      let char_trees: List(Tree(String)) = list.reverse(char_trees_rev)
      let char_list_tree: Tree(List(String)) = sequence_list(char_trees)

      // Technically `Tree(_root, children)` is the whole tree, but we create it
      // eagerly above.
      let Tree(_root, children) =
        char_list_tree
        |> map_tree(fn(char_list) { string.join(char_list, "") })

      children
    }

    let tree = Tree(generated_string, shrink())

    #(tree, seed)
  })
}

/// `string_generic(char_generator, length_generator)` generates strings with 
/// characters from `char_generator` and lengths from `length_generator`.
/// 
pub fn string_generic(
  char_generator: Generator(String),
  length_generator: Generator(Int),
) -> Generator(String) {
  length_generator
  |> bind(string_with_length_from(char_generator, _))
}

/// `string() generates strings with the default character generator and the 
/// default length generator.
/// 
pub fn string() -> Generator(String) {
  bind(small_positive_or_zero_int(), fn(length) {
    string_with_length_from(char(), length)
  })
}

/// `string_non_empty()` generates non-empty strings with the default character 
/// generator and the default length generator.
/// 
pub fn string_non_empty() -> Generator(String) {
  bind(small_strictly_positive_int(), fn(length) {
    string_with_length_from(char(), length)
  })
}

/// `string_with_length(length)` generates strings of the given `length` with the 
/// default character generator.
/// 
pub fn string_with_length(length: Int) -> Generator(String) {
  string_with_length_from(char(), length)
}

/// `string_from(char_generator)` generates strings from the given character generator 
/// using the default length generator.
/// 
pub fn string_from(char_generator: Generator(String)) -> Generator(String) {
  bind(small_positive_or_zero_int(), fn(length) {
    string_with_length_from(char_generator, length)
  })
}

/// `string_non_empty_from(char_generator)` generates non-empty strings from the given 
/// character generator using the default length generator.
/// 
pub fn string_non_empty_from(
  char_generator: Generator(String),
) -> Generator(String) {
  bind(small_strictly_positive_int(), fn(length) {
    string_with_length_from(char_generator, length)
  })
}

// MARK: Lists

fn list_generic_loop(
  n: Int,
  acc: Tree(List(a)),
  element_generator: Generator(a),
  seed: Seed,
) -> #(Tree(List(a)), Seed) {
  case n <= 0 {
    True -> #(acc, seed)
    False -> {
      let Generator(generate) = element_generator
      let #(tree, seed) = generate(seed)

      list_generic_loop(
        n - 1,
        map2_tree(list_cons, tree, acc),
        element_generator,
        seed,
      )
    }
  }
}

/// `list_generic(element_generator, min_len, max_len)` generates lists of 
/// elements from `element_generator` with lengths between `min_len` and 
/// `max_len`, inclusive.
///  
/// Shrinks first on the number of elements, then on the elements themselves.
/// 
pub fn list_generic(
  element_generator: Generator(a),
  min_length min_len: Int,
  max_length max_len: Int,
) -> Generator(List(a)) {
  int_uniform_inclusive(min_len, max_len)
  |> bind(fn(length) {
    Generator(fn(seed) {
      list_generic_loop(length, return_tree([]), element_generator, seed)
    })
  })
}

// MARK: Dicts

/// `dict_generic(key_generator, value_generator, max_len)` generates dictionaries with keys
/// from `key_generator` and values from `value_generator` with lengths up to `max_len`.
/// 
/// Shrinks on size then on elements.
/// 
pub fn dict_generic(
  key_generator key_generator: Generator(key),
  value_generator value_generator: Generator(value),
  max_length max_length: Int,
) -> Generator(Dict(key, value)) {
  tuple2(key_generator, value_generator)
  |> list_generic(0, max_length)
  |> map(dict.from_list)
}

// MARK: Sets

/// `set_generic(element_generator, max_len)` generates sets of elements from 
/// `element_generator`.
/// 
/// Shrinks first on the number of elements, then on the elements themselves.
/// 
pub fn set_generic(element_generator: Generator(a), max_length max_len: Int) {
  list_generic(element_generator, 0, max_len)
  |> map(set.from_list)
}

// MARK: Other

type GenerateOption {
  GenerateNone
  GenerateSome
}

fn generate_option() -> random.Generator(GenerateOption) {
  prng_random.weighted(#(15, GenerateNone), [#(85, GenerateSome)])
}

/// `option(gen)` is an `Option` generator that uses `gen` to generate `Some` 
/// values.  Shrinks towards `None` then towards shrinks of `gen`.
/// 
pub fn option(generator: Generator(a)) -> Generator(Option(a)) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(generate_option, seed) = random.step(generate_option(), seed)

    case generate_option {
      GenerateNone -> #(return_tree(None), seed)
      GenerateSome -> {
        let #(tree, seed) = generate(seed)

        #(option_tree(tree), seed)
      }
    }
  })
}

/// `nil()` is the `Nil` generator. It always returns `Nil` and does not shrink.
/// 
pub fn nil() -> Generator(Nil) {
  Generator(fn(seed) { #(return_tree(Nil), seed) })
}

/// `bool()` generates booleans and shrinks towards `False`.
/// 
pub fn bool() -> Generator(Bool) {
  Generator(fn(seed) {
    let #(bool, seed) = prng_random.choose(True, False) |> random.step(seed)

    let tree = case bool {
      True -> Tree(True, iterator.once(fn() { return_tree(False) }))
      False -> return_tree(False)
    }

    #(tree, seed)
  })
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: TestError
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pub opaque type TestError(a) {
  TestError(
    original_value: a,
    shrunk_value: a,
    shrink_steps: Int,
    error_msg: String,
  )
}

pub fn new_test_error(
  original_value orig: a,
  shrunk_value shrunk: a,
  shrink_steps steps: Int,
  error_msg error_msg: String,
) -> TestError(a) {
  TestError(
    original_value: orig,
    shrunk_value: shrunk,
    shrink_steps: steps,
    error_msg: error_msg,
  )
}

fn test_error_to_string(test_error: TestError(a)) -> String {
  "TestError[original_value: "
  <> string.inspect(test_error.original_value)
  <> "; shrunk_value: "
  <> string.inspect(test_error.shrunk_value)
  <> "; shrink_steps: "
  <> string.inspect(test_error.shrink_steps)
  <> "; error: "
  <> test_error.error_msg
  <> ";]"
}

@external(erlang, "qcheck_ffi", "fail")
@external(javascript, "./qcheck_ffi.mjs", "fail")
fn do_fail(msg: String) -> a

fn fail(test_error_display: String) -> a {
  do_fail(test_error_display)
}

// If this returned an opaque Exn type then you couldn't mess up the
// `test_error_message.rescue` call later, but it could potentially conflict
// with non-gleeunit test frameworks, depending on how they deal with
// exceptions.
pub fn failwith(
  original_value original_value: a,
  shrunk_value shrunk_value: a,
  shrink_steps shrink_steps: Int,
  error_msg error_msg: String,
) -> b {
  new_test_error(
    original_value: original_value,
    shrunk_value: shrunk_value,
    shrink_steps: shrink_steps,
    error_msg: error_msg,
  )
  |> test_error_to_string
  |> fail
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: TestErrorMessage
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

pub opaque type TestErrorMessage {
  TestErrorMessage(
    original_value: String,
    shrunk_value: String,
    shrink_steps: String,
  )
}

pub fn test_error_message_original_value(msg: TestErrorMessage) -> String {
  msg.original_value
}

pub fn test_error_message_shrunk_value(msg: TestErrorMessage) -> String {
  msg.shrunk_value
}

pub fn test_error_message_shrink_steps(msg: TestErrorMessage) -> String {
  msg.shrink_steps
}

fn new_test_error_message(
  original_value original_value: String,
  shrunk_value shrunk_value: String,
  shrink_steps shrink_steps: String,
) -> TestErrorMessage {
  TestErrorMessage(
    original_value: original_value,
    shrunk_value: shrunk_value,
    shrink_steps: shrink_steps,
  )
}

fn regex_first_submatch(
  pattern pattern: String,
  in value: String,
) -> Result(String, String) {
  regex.from_string(pattern)
  // Convert regex.CompileError to a String
  |> result.map_error(string.inspect)
  // Apply the regular expression
  |> result.map(regex.scan(_, value))
  // We should see only a single match
  |> result.then(fn(matches) {
    case matches {
      [match] -> Ok(match)
      _ -> Error("expected exactly one match")
    }
  })
  // We should see only a single successful submatch
  |> result.then(fn(match) {
    let regex.Match(_content, submatches) = match

    case submatches {
      [Some(submatch)] -> Ok(submatch)
      _ -> Error("expected exactly one submatch")
    }
  })
}

/// Mainly for asserting values in qcheck internal tests.
fn test_error_message_get_original_value(
  test_error_str: String,
) -> Result(String, String) {
  regex_first_submatch(pattern: "original_value: (.+?);", in: test_error_str)
}

/// Mainly for asserting values in qcheck internal tests.
fn test_error_message_get_shrunk_value(
  test_error_str: String,
) -> Result(String, String) {
  regex_first_submatch(pattern: "shrunk_value: (.+?);", in: test_error_str)
}

/// Mainly for asserting values in qcheck internal tests.
fn test_error_message_get_shrink_steps(
  test_error_str: String,
) -> Result(String, String) {
  regex_first_submatch(pattern: "shrink_steps: (.+?);", in: test_error_str)
}

/// This function should only be called to rescue a function that my call
/// `failwith` at some point to raise an exception.  It will likely 
/// raise otherwise.
pub fn rescue(thunk: fn() -> a) -> Result(a, TestErrorMessage) {
  case rescue_error(thunk) {
    Ok(a) -> Ok(a)
    Error(err) -> {
      let assert Ok(test_error_message) = {
        use original_value <- result.then(test_error_message_get_original_value(
          err,
        ))
        use shrunk_value <- result.then(test_error_message_get_shrunk_value(err))
        use shrink_steps <- result.then(test_error_message_get_shrink_steps(err))

        Ok(new_test_error_message(
          original_value: original_value,
          shrunk_value: shrunk_value,
          shrink_steps: shrink_steps,
        ))
      }

      Error(test_error_message)
    }
  }
}

@external(erlang, "qcheck_ffi", "rescue_error")
@external(javascript, "./qcheck_ffi.mjs", "rescue_error")
pub fn rescue_error(f: fn() -> a) -> Result(a, String)

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Try
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Utils 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fn list_return(a) {
  [a]
}

fn ok_exn(result) {
  let assert Ok(x) = result

  x
}

fn list_cons(x, xs) {
  [x, ..xs]
}

// TODO: Could this be simplified?
fn int_to_char(n: Int) -> String {
  n
  |> string.utf_codepoint
  |> ok_exn
  |> list_return
  |> string.from_utf_codepoints
}

fn char_to_int(c: String) -> Int {
  string.to_utf_codepoints(c)
  |> list.first
  |> ok_exn
  |> string.utf_codepoint_to_int
}

// Assumes that the args are properly ordered.
fn pick_origin_within_range(low: Int, high: Int, goal goal: Int) {
  case low > goal {
    True -> low
    False ->
      case high < goal {
        True -> high
        False -> goal
      }
  }
}

// Assumes that the args are properly ordered.
fn pick_origin_within_range_float(low: Float, high: Float, goal goal: Float) {
  case low >. goal {
    True -> low
    False ->
      case high <. goal {
        True -> high
        False -> goal
      }
  }
}

fn do_filter_map(
  it: iterator.Iterator(a),
  f: fn(a) -> Option(b),
) -> iterator.Step(b, iterator.Iterator(a)) {
  case iterator.step(it) {
    iterator.Done -> iterator.Done
    iterator.Next(x, it) -> {
      case f(x) {
        None -> do_filter_map(it, f)
        Some(y) -> iterator.Next(y, it)
      }
    }
  }
}

fn filter_map(
  it: iterator.Iterator(a),
  f: fn(a) -> Option(b),
) -> iterator.Iterator(b) {
  iterator.unfold(it, do_filter_map(_, f))
}

// The curry functions from the stdlib are now deprecated, so we use these
// instead.

fn curry2(f: fn(x1, x2) -> y) -> fn(x1) -> fn(x2) -> y {
  fn(x1) { fn(x2) { f(x1, x2) } }
}

fn curry3(f: fn(x1, x2, x3) -> y) -> fn(x1) -> fn(x2) -> fn(x3) -> y {
  fn(x1) { fn(x2) { fn(x3) { f(x1, x2, x3) } } }
}

fn curry4(
  f: fn(x1, x2, x3, x4) -> y,
) -> fn(x1) -> fn(x2) -> fn(x3) -> fn(x4) -> y {
  fn(x1) { fn(x2) { fn(x3) { fn(x4) { f(x1, x2, x3, x4) } } } }
}

fn curry5(
  f: fn(x1, x2, x3, x4, x5) -> y,
) -> fn(x1) -> fn(x2) -> fn(x3) -> fn(x4) -> fn(x5) -> y {
  fn(x1) { fn(x2) { fn(x3) { fn(x4) { fn(x5) { f(x1, x2, x3, x4, x5) } } } } }
}

fn curry6(
  f: fn(x1, x2, x3, x4, x5, x6) -> y,
) -> fn(x1) -> fn(x2) -> fn(x3) -> fn(x4) -> fn(x5) -> fn(x6) -> y {
  fn(x1) {
    fn(x2) {
      fn(x3) { fn(x4) { fn(x5) { fn(x6) { f(x1, x2, x3, x4, x5, x6) } } } }
    }
  }
}
