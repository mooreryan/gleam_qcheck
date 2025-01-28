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
//// For full usage examples, see the project README.
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
//// - [with_seed](#with_seed)
//// 
//// 
//// ## Generators
//// 
//// The exact distributions of individual generators are considered an 
//// implementation detail, and may change without a major version update.  
//// For example, if the `option` generator currently produced `None` 
//// approximately 25% of the time, but that distribution was changed to produce 
//// `None` 50% of the time instead, that would NOT be considered a breaking 
//// change.
//// 
//// - The [Generator](#Generator) type
//// 
//// Here is a list of generator functions grouped by category.
//// 
//// ### Combinators
//// 
//// - [return](#return)
//// - [parameter](#parameter)
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
////  - [int_small_positive_or_zero](#int_small_positive_or_zero)
////  - [int_small_strictly_positive](#int_small_strictly_positive)
//// 
//// ### Unicode codepoints (`UtfCodepoint`)
//// 
//// - [utf_codepoint](#utf_codepoint)
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
////  - [char_utf_codepoint](#char_utf_codepoint)
////  - [char_uppercase](#char_uppercase)
////  - [char_lowercase](#char_lowercase)
////  - [char_digit](#char_digit)
////  - [char_printable_uniform](#char_printable_uniform)
////  - [char_uniform](#char_uniform)
////  - [char_alpha](#char_alpha)
////  - [char_alpha_numeric](#char_alpha_numeric)
////  - [char_from_list](#char_from_list)
////  - [char_whitespace](#char_whitespace)
////  - [char_printable](#char_printable)
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
//// Note that for the string generators, "length" refers to the number of 
//// codepoints rather than the number of grapheme clusters as `string.length` 
//// from the stdlib does.  This is a consequence of the current generation 
//// strategy, and may change in the future.
//// 
//// ### Bit arrays
//// 
//// Bit array shrinking is a bit wonky compared to shrinking of the other types.  
//// 
//// These functions will generate bit arrays that cause runtime crashes when 
//// targeting JavaScript.
//// 
//// - [bit_array](#bit_array)
//// - [bit_array_non_empty](#bit_array_non_empty)
//// - [bit_array_with_size_from](#bit_array_with_size_from)
//// - [bit_array_with_size](#bit_array_with_size)
//// 
//// #### Bit arrays (UTF-8 encoded)
//// 
//// These functions will not generate bit arrays that cause runtime crashes when 
//// targeting JavaScript.
////
//// - [bit_array_utf8](#bit_array_utf8)
//// - [bit_array_utf8_non_empty](#bit_array_utf8_non_empty)
//// - [bit_array_utf8_with_size](#bit_array_utf8_with_size)
//// - [bit_array_utf8_with_size_from](#bit_array_utf8_with_size_from)
//// 
//// #### Bit arrays (Byte-aligned)
//// 
//// These functions will not generate bit arrays that cause runtime crashes when 
//// targeting JavaScript.
////
//// - [bit_array_byte_aligned](#bit_array_byte_aligned)
//// - [bit_array_byte_aligned_non_empty](#bit_array_byte_aligned_non_empty)
//// - [bit_array_byte_aligned_with_size](#bit_array_byte_aligned_with_size)
//// - [bit_array_byte_aligned_with_size_from](#bit_array_byte_aligned_with_size_from)
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
//// ## Debug Generators
//// 
//// These functions aren't meant to be used directly in tests.  They are 
//// provided to help debug or investigate what values and shrinks that a 
//// generator produces.
//// 
//// - [generate](#generate)
//// - [generate_tree](#generate_tree)
//// 
//// ## Seeding generators
//// 
//// - The [Seed](#Seed) type
//// - [seed_new](#seed_new)
//// - [seed_random](#seed_random)
//// 
//// ## Shrinking
//// 
//// There are some public functions for dealing with shrinks and shrinking.
//// Similar to the Tree functions, you often won't need to use these directly.
////
//// - [shrink_atomic](#shrink_atomic)
//// - [shrink.int_towards](#shrink.int_towards)
//// - [shrink.int_towards_zero](#shrink.int_towards_zero)
//// - [shrink.float_towards](#shrink.float_towards)
//// - [shrink.float_towards_zero](#shrink.float_towards_zero)
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

// MARK: Imports

import exception
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/regexp
import gleam/result
import gleam/set
import gleam/string
import gleam/string_tree.{type StringTree}
import gleam/yielder
import qcheck/random
import qcheck/shrink
import qcheck/tree.{type Tree, Tree}

const ascii_a_lowercase: Int = 97

const ascii_a_uppercase: Int = 65

const ascii_nine: Int = 57

const ascii_space: Int = 32

const ascii_tilde: Int = 126

const ascii_z_lowercase: Int = 122

const ascii_z_uppercase: Int = 90

const ascii_zero: Int = 48

const min_valid_codepoint: Int = 0

const max_valid_codepoint: Int = 0x10FFFF

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
      let #(tree, seed) = generate(config.seed)
      let Tree(value, _shrinks) = tree

      case try(fn() { property(value) }) {
        NoPanic(True) -> {
          do_run(
            config
              |> with_seed(seed),
            generator,
            property,
            i + 1,
          )
        }
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
      let #(tree, seed) = generate(config.seed)
      let Tree(value, _shrinks) = tree

      case try(fn() { property(value) }) {
        NoPanic(Ok(_)) ->
          do_run_result(
            config
              |> with_seed(seed),
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
    |> yielder.first

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
    |> yielder.first

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

fn filter_map(
  it: yielder.Yielder(a),
  f: fn(a) -> Option(b),
) -> yielder.Yielder(b) {
  yielder.unfold(it, do_filter_map(_, f))
}

fn do_filter_map(
  it: yielder.Yielder(a),
  f: fn(a) -> Option(b),
) -> yielder.Step(b, yielder.Yielder(a)) {
  case yielder.step(it) {
    yielder.Done -> yielder.Done
    yielder.Next(x, it) -> {
      case f(x) {
        None -> do_filter_map(it, f)
        Some(y) -> yielder.Next(y, it)
      }
    }
  }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Seeds 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// A type representing a seed value used to initialize random generators.
/// 
pub type Seed =
  random.Seed

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
  random.seed(n)
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
  random.seed_random()
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Test config 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// Configuration for the property-based testing.
/// 
/// - `test_count`: The number of tests to run for each property.
/// - `max_retries`: The number of times to retry the tested property while 
///   shrinking.
/// - `seed`: The seed for the random generator.
pub opaque type Config {
  Config(test_count: Int, max_retries: Int, seed: Seed)
}

const default_test_count: Int = 1000

const default_max_retries: Int = 1

/// `default()` returns the default configuration for the property-based testing.
/// 
pub fn default_config() -> Config {
  Config(
    test_count: default_test_count,
    max_retries: default_max_retries,
    seed: seed_random(),
  )
}

/// `config(test_count, max_retries, seed)` builds a new `Config`.
/// 
/// Any invalid arguments will be replaced with reasonable defaults.
/// 
pub fn config(
  test_count test_count: Int,
  max_retries max_retries: Int,
  seed seed: Seed,
) -> Config {
  // Use the `with_*` functions so we get their validation logic.
  default_config()
  |> with_test_count(test_count)
  |> with_max_retries(max_retries)
  |> with_seed(seed)
}

/// `with_test_count()` returns a new configuration with the given test count.
/// 
/// If `test_count <= 0`, then it will be adjusted to a valid value.
///  
pub fn with_test_count(config: Config, test_count: Int) -> Config {
  let test_count = case test_count <= 0 {
    True -> default_test_count
    False -> test_count
  }

  Config(..config, test_count: test_count)
}

/// `with_max_retries()` returns a new configuration with the given max retries.
/// 
/// If `max_retries < 0`, then it will be adjusted to a valid value.
/// 
pub fn with_max_retries(config: Config, max_retries: Int) -> Config {
  let max_retries = case max_retries < 0 {
    True -> default_max_retries
    False -> max_retries
  }

  Config(..config, max_retries: max_retries)
}

/// `with_seed()` returns a new configuration with the given random seed.
pub fn with_seed(config: Config, seed: Seed) -> Config {
  Config(..config, seed: seed)
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Generators 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// `Generator(a)` is a random generator for values of type `a`.
/// 
/// While this type is not opaque (and has a public constructor), you should 
/// generally prefer to use the built-in generators or combinators like `map`, 
/// `bind`, etc.  Direct generator construction should rarely be done.
/// 
pub type Generator(a) {
  Generator(fn(Seed) -> #(Tree(a), Seed))
}

/// `generator(random_generator, tree)` creates a new generator.
/// 
/// The `random_generator` produces random values of type `a`, while the `tree` 
/// function takes those values and creates a shrink tree for them.
/// 
/// This is a low-level function for building custom generators. Most users 
/// should use the built-in generators or combinators like `map`, `bind`, etc.
/// 
pub fn generator(
  random_generator: random.Generator(a),
  tree: fn(a) -> Tree(a),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(generated_value, next_seed) = random.step(random_generator, seed)

    #(tree(generated_value), next_seed)
  })
}

// MARK: Debug Generators

/// `generate(generator, n, seed)` generates `n` values using `generator` and 
/// the starting `seed`.
/// 
///   Discards any shrinks.
pub fn generate(
  generator: Generator(a),
  number_to_generate: Int,
  seed: Seed,
) -> List(a) {
  do_gen(generator, number_to_generate, seed, [], 0)
}

fn do_gen(
  generator: Generator(a),
  number_to_generate: Int,
  seed: Seed,
  acc: List(a),
  k: Int,
) -> List(a) {
  case k >= number_to_generate {
    True -> acc
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(seed)
      let Tree(value, _shrinks) = tree
      do_gen(generator, number_to_generate, seed, [value, ..acc], k + 1)
    }
  }
}

/// `generate_tree(generator, seed)` generates a value of type `a` and its 
/// shrinks using 
/// the generator `generator`.
/// 
pub fn generate_tree(generator: Generator(a), seed: Seed) -> #(Tree(a), Seed) {
  let Generator(generate) = generator

  generate(seed)
}

// MARK: Combinators

/// `return(a)` creates a generator that always returns `a` and does not shrink.
/// 
/// It is an alias for `constant(a)`.
/// 
pub fn return(a: a) -> Generator(a) {
  Generator(fn(seed) { #(tree.return(a), seed) })
}

/// `constant(a)` creates a generator that always returns `a` and does not shrink.
/// 
/// It is an alias for `return(a)`.
///
pub fn constant(a: a) -> Generator(a) {
  return(a)
}

/// `parameter(f)` is used in constructing curried functions for the applicative 
/// style of building generators.
/// 
/// ### Example
/// 
/// ```
/// import qcheck
/// 
/// type Box {
///   Box(x: Int, y: Int, w: Int, h: Int)
/// }
/// 
/// fn box_generator() {
///   qcheck.return({
///     use x <- qcheck.parameter
///     use y <- qcheck.parameter
///     use w <- qcheck.parameter
///     use h <- qcheck.parameter
///     Box(x:, y:, w:, h:)
///   })
///   |> qcheck.apply(qcheck.int_uniform_inclusive(-100, 100))
///   |> qcheck.apply(qcheck.int_uniform_inclusive(-100, 100))
///   |> qcheck.apply(qcheck.int_uniform_inclusive(1, 100))
///   |> qcheck.apply(qcheck.int_uniform_inclusive(1, 100))
/// }
/// 
/// pub fn parameter_example__test() {
///   use _box <- qcheck.given(box_generator())
/// 
///   // Test some interesting property of boxes here.
/// 
///   // (This `True` is a standin for your property.)
///   True
/// }
/// ```
/// 
pub fn parameter(f: fn(x) -> y) -> fn(x) -> y {
  f
}

/// `map(generator, f)` transforms the generator `generator` by applying `f` to 
/// each generated value.  Shrinks as `generator` shrinks, but with `f` applied.
/// 
pub fn map(generator: Generator(a), f: fn(a) -> b) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree = tree.map(tree, f)

    #(tree, seed)
  })
}

/// `bind(generator, f)` generates a value of type `a` with `generator`, then 
/// passes that value to `f`, which uses it to generate values of type `b`.
/// 
pub fn bind(generator: Generator(a), f: fn(a) -> Generator(b)) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree =
      tree.bind(tree, fn(x) {
        let Generator(generate) = f(x)
        let #(tree, _seed) = generate(seed)
        tree
      })

    #(tree, seed)
  })
}

/// `then` is an alias for `bind`.
/// 
pub fn then(generator: Generator(a), f: fn(a) -> Generator(b)) -> Generator(b) {
  bind(generator, f)
}

/// `apply(f, x)` applies a function generator, `f`, and an argument generator, 
/// `x`, into a result generator.
/// 
pub fn apply(f: Generator(fn(a) -> b), x: Generator(a)) -> Generator(b) {
  let Generator(f) = f
  let Generator(x) = x

  Generator(fn(seed) {
    let #(y_of_x, seed) = x(seed)
    let #(y_of_f, seed) = f(seed)
    let tree = tree.apply(y_of_f, y_of_x)

    #(tree, seed)
  })
}

/// `map2(g1, g2, f)` transforms two generators, `g1` and `g2`, by applying `f` 
/// to each pair of generated values.
/// 
pub fn map2(
  g1: Generator(x1),
  g2: Generator(x2),
  f: fn(x1, x2) -> y,
) -> Generator(y) {
  return({
    use x1 <- parameter
    use x2 <- parameter
    f(x1, x2)
  })
  |> apply(g1)
  |> apply(g2)
}

/// `map3(g1, g2, g3, f)` transforms three generators, `g1`, `g2`, and `g3`, by
/// applying `f` to each triple of generated values.
/// 
pub fn map3(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  f: fn(x1, x2, x3) -> y,
) -> Generator(y) {
  return({
    use x1 <- parameter
    use x2 <- parameter
    use x3 <- parameter
    f(x1, x2, x3)
  })
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
}

/// `map4(g1, g2, g3, g4, f)` transforms four generators, `g1`, `g2`, `g3`, and
/// `g4`, by applying `f` to each quadruple of generated values.
/// 
pub fn map4(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  g4: Generator(x4),
  f: fn(x1, x2, x3, x4) -> y,
) -> Generator(y) {
  return({
    use x1 <- parameter
    use x2 <- parameter
    use x3 <- parameter
    use x4 <- parameter
    f(x1, x2, x3, x4)
  })
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
  |> apply(g4)
}

/// `map5(g1, g2, g3, g4, g5, f)` transforms five generators, `g1`, `g2`, `g3`,
/// `g4`, and `g5`, by applying `f` to each quintuple of generated values.
/// 
pub fn map5(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  g4: Generator(x4),
  g5: Generator(x5),
  f: fn(x1, x2, x3, x4, x5) -> y,
) -> Generator(y) {
  return({
    use x1 <- parameter
    use x2 <- parameter
    use x3 <- parameter
    use x4 <- parameter
    use x5 <- parameter
    f(x1, x2, x3, x4, x5)
  })
  |> apply(g1)
  |> apply(g2)
  |> apply(g3)
  |> apply(g4)
  |> apply(g5)
}

/// `map6(g1, g2, g3, g4, g5, g6, f)` transforms six generators, `g1`, `g2`, `g3`,
/// `g4`, `g5`, and `g6`, by applying `f` to each sextuple of generated values.
/// 
pub fn map6(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  g4: Generator(x4),
  g5: Generator(x5),
  g6: Generator(x6),
  f: fn(x1, x2, x3, x4, x5, x6) -> y,
) -> Generator(y) {
  return({
    use x1 <- parameter
    use x2 <- parameter
    use x3 <- parameter
    use x4 <- parameter
    use x5 <- parameter
    use x6 <- parameter
    f(x1, x2, x3, x4, x5, x6)
  })
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
pub fn tuple2(g1: Generator(x1), g2: Generator(x2)) -> Generator(#(x1, x2)) {
  use x1, x2 <- map2(g1, g2)
  #(x1, x2)
}

/// `tuple3(g1, g2, g3)` generates a tuple of three values, one each from
/// generators `g1`, `g2`, and `g3`.
/// 
pub fn tuple3(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
) -> Generator(#(x1, x2, x3)) {
  use x1, x2, x3 <- map3(g1, g2, g3)
  #(x1, x2, x3)
}

/// `tuple4(g1, g2, g3, g4)` generates a tuple of four values, one each from
/// generators `g1`, `g2`, `g3`, and `g4`.
/// 
pub fn tuple4(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  g4: Generator(x4),
) -> Generator(#(x1, x2, x3, x4)) {
  use x1, x2, x3, x4 <- map4(g1, g2, g3, g4)
  #(x1, x2, x3, x4)
}

/// `tuple5(g1, g2, g3, g4, g5)` generates a tuple of five values, one each from
/// generators `g1`, `g2`, `g3`, `g4`, and `g5`.
/// 
pub fn tuple5(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  g4: Generator(x4),
  g5: Generator(x5),
) -> Generator(#(x1, x2, x3, x4, x5)) {
  use x1, x2, x3, x4, x5 <- map5(g1, g2, g3, g4, g5)
  #(x1, x2, x3, x4, x5)
}

/// `tuple6(g1, g2, g3, g4, g5, g6)` generates a tuple of six values, one each 
/// from generators `g1`, `g2`, `g3`, `g4`, `g5`, and `g6`.
/// 
pub fn tuple6(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
  g4: Generator(x4),
  g5: Generator(x5),
  g6: Generator(x6),
) -> Generator(#(x1, x2, x3, x4, x5, x6)) {
  use x1, x2, x3, x4, x5, x6 <- map6(g1, g2, g3, g4, g5, g6)
  #(x1, x2, x3, x4, x5, x6)
}

/// `from_generators(generator, generators)` chooses a generator from the given 
/// generators, then chooses a value from that generator. 
/// 
/// This generator will always produce values, since at least one generator must 
/// always be provided.
/// 
pub fn from_generators(
  generator: Generator(a),
  generators: List(Generator(a)),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      random.uniform(generator, generators)
      |> random.step(seed)

    generator(seed)
  })
}

/// `from_float_weighted_generators(generator, generators)` chooses a generator 
/// from the given generators weighted by the given float weights, then chooses 
/// a value from that generator.
/// 
/// You should generally prefer `from_weighted_generators` as it is much faster.
/// 
pub fn from_float_weighted_generators(
  generator: #(Float, Generator(a)),
  generators: List(#(Float, Generator(a))),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      random.float_weighted(generator, generators)
      |> random.step(seed)

    generator(seed)
  })
}

/// `from_float_generators(generator, generators)` chooses a generator from the 
/// given generators weighted by the integer weights, then chooses a value from 
/// that generator.
/// 
/// You should generally prefer this function over 
/// `from_float_weighted_generators` as this function is faster.
/// 
pub fn from_weighted_generators(
  generator: #(Int, Generator(a)),
  generators: List(#(Int, Generator(a))),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      random.weighted(generator, generators)
      |> random.step(seed)

    generator(seed)
  })
}

// MARK: Sized generators

/// Represents a `Generator` with a size.
/// 
type SizedGenerator(a) =
  fn(Int) -> Generator(a)

/// Creates a generator from a sized generator by first generating a size
/// using the `size_generator`, then passing the result to the 
/// `sized_generator`.
///
/// Shrinks on the size first, then on the generator.
/// 
/// ### Example
/// 
/// Generate digit strings sized between 10 and 20 digits.
/// 
/// ```
/// string_with_length_from(char_digit()) 
/// |> sized_from(int_uniform_inclusive(10, 20))
/// ```
///
pub fn sized_from(
  sized_generator: SizedGenerator(a),
  size_generator: Generator(Int),
) -> Generator(a) {
  size_generator |> bind(sized_generator)
}

// MARK: Ints

/// `int_small_positive_or_zero()` generates small integers well suited for 
/// modeling the sizes of sized elements like lists or strings.
/// 
/// Smaller numbers are more likely than larger numbers.
/// 
/// Shrinks towards `0`.
/// 
pub fn int_small_positive_or_zero() -> Generator(Int) {
  generator(
    random.int(0, 100)
      |> random.then(fn(x) {
        case x < 75 {
          True -> random.int(0, 10)
          False -> random.int(0, 100)
        }
      }),
    fn(n) { tree.new(root: n, shrink: shrink.int_towards_zero()) },
  )
}

/// `int_small_strictly_positive()` generates small integers strictly greater
/// than `0`.
/// 
pub fn int_small_strictly_positive() -> Generator(Int) {
  int_small_positive_or_zero()
  |> map(int.add(_, 1))
}

/// `int_uniform_inclusive(from, to)` generates integers uniformly distributed
/// between `from` and `to`, inclusive.
/// 
/// Shrinks towards `0`, but won't shrink outside of the range `[from, to]`.
/// 
/// Note: If you pass the parameters backwards, e.g., 
/// `int_uniform_inclusive(5, 2)` it will be treated the same as 
/// `int_uniform_inclusive(2, 5)`.
/// 
pub fn int_uniform_inclusive(from low: Int, to high: Int) -> Generator(Int) {
  let #(low, high) = case low <= high {
    True -> #(low, high)
    False -> #(high, low)
  }

  generator(random.int(low, high), fn(n) {
    let origin = pick_origin_within_range(low, high, goal: 0)

    tree.new(root: n, shrink: shrink.int_towards(origin))
  })
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
  // Gleam's float.power will return an Error if the base is negative, but here
  // it is known to always be positive (e).  On JavaScript, if `x` is too big,
  // it will return Infinity.  However, Gleam doesn't treat this case as an
  // Error  and your code will be anyway.  So the `let assert` shouldn't crash.
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
    let #(y, seed) = random.choose(1.0, -1.0) |> random.step(seed)
    let #(z, seed) = random.choose(1.0, -1.0) |> random.step(seed)

    // The QCheck2.Gen.float code has this double multiply in it. Actually not
    // sure about that.
    let generated_value = exp(x) *. y *. z

    let tree = tree.new(generated_value, shrink.float_towards_zero())

    #(tree, seed)
  })
}

/// `float_uniform_inclusive(from, to)` generates floats uniformly distributed
/// between `from` and `to`, inclusive.
/// 
/// Shrinks towards `0.0`, but won't shrink outside of the range `[from, to]`.
/// 
/// Note: If you pass the parameters backwards, e.g., 
/// `float_uniform_inclusive(5.0, 2.0)` it will be treated the same as 
/// `float_uniform_inclusive(2.0, 5.0)`.
/// 
pub fn float_uniform_inclusive(from low: Float, to high: Float) {
  let #(low, high) = case low <=. high {
    True -> #(low, high)
    False -> #(high, low)
  }

  generator(random.float(low, high), fn(n) {
    let origin = pick_origin_within_range_float(low, high, goal: 0.0)

    tree.new(root: n, shrink: shrink.float_towards(origin))
  })
}

// MARK: Characters

// Though gleam doesn't have a `Char` type, we need these one-character string
// generators so that we can shrink the `Generator(String)` type properly.

const char_min_value: Int = 0

const char_max_value: Int = 255

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
/// Note: if you provide a range that it outside the range of valid codepoints, 
/// a default range will be chosen for you.
/// 
pub fn char_uniform_inclusive(from low: Int, to high: Int) -> Generator(String) {
  let #(low, high) = case low <= high {
    True -> #(low, high)
    False -> #(high, low)
  }

  // It is okay if the min and max are the same.
  let low = int.clamp(low, min: min_valid_codepoint, max: max_valid_codepoint)
  let high = int.clamp(high, min: min_valid_codepoint, max: max_valid_codepoint)

  let origin = pick_origin_within_range(low, high, goal: ascii_a_lowercase)
  let shrink = shrink.int_towards(origin)

  Generator(fn(seed) {
    let #(n, seed) = random.int(low, high) |> random.step(seed)

    let tree =
      tree.new(n, shrink)
      // If user crafts a range that generates lots of invalid codepoints, then
      // the nice shrinking will get a bit weird.  But origin should be valid
      // unless there is an implementation error, since the "goal" above should
      // always be valid.
      |> tree.map(int_to_char(_, default: origin))

    #(tree, seed)
  })
}

/// `char_uppercase()` generates uppercase (ASCII) letters.
/// 
pub fn char_uppercase() -> Generator(String) {
  char_uniform_inclusive(ascii_a_uppercase, ascii_z_uppercase)
}

/// `char_lowercase()` generates lowercase (ASCII) letters.
/// 
pub fn char_lowercase() -> Generator(String) {
  char_uniform_inclusive(ascii_a_lowercase, ascii_z_lowercase)
}

/// `char_digit()` generates digits from `0` to `9`, inclusive.
/// 
pub fn char_digit() -> Generator(String) {
  char_uniform_inclusive(ascii_zero, ascii_nine)
}

/// `char_printable_uniform()` generates printable ASCII characters.
/// 
/// Shrinks to `"a"`.
/// 
pub fn char_printable_uniform() -> Generator(String) {
  char_uniform_inclusive(ascii_space, ascii_tilde)
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
  from_generators(char_uppercase(), [char_lowercase()])
}

/// `char_alpha_numeric()` generates alphanumeric (ASCII) characters.
/// 
pub fn char_alpha_numeric() -> Generator(String) {
  from_weighted_generators(#(26, char_uppercase()), [
    #(26, char_lowercase()),
    #(10, char_digit()),
  ])
}

/// `char_from_list(char, chars)` generates characters from the given list of
/// characters.
/// 
/// The name is slightly weird since there is a single argument plus the list, 
/// but doing it this way avoids the case of an empty list crashing your 
/// program.  E.g., `char_from_list([])` would crash your test suite, so a 
/// single char must always be provided.
/// 
pub fn char_from_list(char: String, chars: List(String)) -> Generator(String) {
  let hd = char_to_int(char)
  let tl = list.map(chars, char_to_int)

  // Take the char with the minimum int representation as the shrink target.
  let shrink_target = list.fold(tl, hd, int.min)

  Generator(fn(seed) {
    let #(n, seed) = random.uniform(hd, tl) |> random.step(seed)

    let tree =
      tree.new(n, shrink.int_towards(shrink_target))
      |> tree.map(int_to_char(_, default: shrink_target))

    #(tree, seed)
  })
}

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
  // If this assert fails, then we have an implementation bug in the min and max
  // char values.
  let assert [char, ..chars] =
    list.range(char_min_value, char_max_value)
    |> list.filter(char_is_whitespace)
    |> list.map(int_to_char(_, default: ascii_space))

  char_from_list(char, chars)
}

/// `char_printable()` generates printable ASCII characters, with a bias towards
/// alphanumeric characters.
/// 
pub fn char_printable() -> Generator(String) {
  from_weighted_generators(#(381, char_uppercase()), [
    #(381, char_lowercase()),
    #(147, char_digit()),
    #(91, char_printable_uniform()),
  ])
}

pub fn char_utf_codepoint() -> Generator(String) {
  use codepoint <- map(utf_codepoint())
  string.from_utf_codepoints([codepoint])
}

/// `char()` generates characters with a bias towards printable ASCII 
/// characters, while still hitting some edge cases.
/// 
pub fn char() {
  // If these fail, then char_min/max_value are incorrect (implementation bug).
  let assert Ok(min_value) = string.utf_codepoint(char_min_value)
  let assert Ok(max_value) = string.utf_codepoint(char_max_value)

  // TODO add in some charaters in the higher unicode ranges.
  from_weighted_generators(#(340, char_uppercase()), [
    #(340, char_lowercase()),
    #(131, char_digit()),
    #(81, char_printable_uniform()),
    #(89, char_uniform()),
    #(09, return(string.from_utf_codepoints([min_value]))),
    #(09, return(string.from_utf_codepoints([max_value]))),
  ])
}

// MARK: Strings

fn do_gen_string(
  i: Int,
  string_tree: StringTree,
  char_gen: Generator(String),
  char_trees_rev: List(Tree(String)),
  seed: Seed,
) -> #(String, List(Tree(String)), Seed) {
  let Generator(gen_char_tree) = char_gen

  let #(char_tree, seed) = gen_char_tree(seed)

  case i <= 0 {
    True -> #(string_tree.to_string(string_tree), char_trees_rev, seed)
    False -> {
      let Tree(root, _) = char_tree

      do_gen_string(
        i - 1,
        string_tree |> string_tree.append(root),
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
/// Note that for the string generators, "length" refers to the number of 
/// codepoints rather than the number of grapheme clusters as `string.length` 
/// from the stdlib does.  This is a consequence of the current generation 
/// strategy, and may change in the future.
/// 
pub fn string_with_length_from(
  generator: Generator(String),
  length: Int,
) -> Generator(String) {
  Generator(fn(seed) {
    let #(generated_string, char_trees_rev, seed) =
      do_gen_string(length, string_tree.new(), generator, [], seed)

    let shrink = fn() {
      let char_trees: List(Tree(String)) = list.reverse(char_trees_rev)
      let char_list_tree: Tree(List(String)) = tree.sequence_trees(char_trees)

      // Technically `Tree(_root, children)` is the whole tree, but we create it
      // eagerly above.
      let Tree(_root, children) =
        char_list_tree
        |> tree.map(fn(char_list) { string.join(char_list, "") })

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
  bind(int_small_positive_or_zero(), fn(length) {
    string_with_length_from(char(), length)
  })
}

/// `string_non_empty()` generates non-empty strings with the default character 
/// generator and the default length generator.
/// 
pub fn string_non_empty() -> Generator(String) {
  bind(int_small_strictly_positive(), fn(length) {
    string_with_length_from(char(), length)
  })
}

/// `string_with_length(length)` generates strings of the given `length` with the 
/// default character generator.
/// 
/// Note that for the string generators, "length" refers to the number of 
/// codepoints rather than the number of grapheme clusters as `string.length` 
/// from the stdlib does.  This is a consequence of the current generation 
/// strategy, and may change in the future.
///
pub fn string_with_length(length: Int) -> Generator(String) {
  string_with_length_from(char(), length)
}

/// `string_from(char_generator)` generates strings from the given character generator 
/// using the default length generator.
/// 
pub fn string_from(char_generator: Generator(String)) -> Generator(String) {
  bind(int_small_positive_or_zero(), fn(length) {
    string_with_length_from(char_generator, length)
  })
}

/// `string_non_empty_from(char_generator)` generates non-empty strings from the given 
/// character generator using the default length generator.
/// 
pub fn string_non_empty_from(
  char_generator: Generator(String),
) -> Generator(String) {
  bind(int_small_strictly_positive(), fn(length) {
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
        tree.map2(tree, acc, list_cons),
        element_generator,
        seed,
      )
    }
  }
}

/// `list_generic(element_generator, length_generator)` generates lists of 
/// elements from `element_generator` with lengths from `length_generator`.
///  
/// Shrinks first on the number of elements, then on the elements themselves.
/// Will not generate shrinks whose length is  outside of the range specified
/// by the `length_generator`.
/// 
pub fn list_generic(
  element_generator element_generator: Generator(a),
  length_generator length_generator: Generator(Int),
) -> Generator(List(a)) {
  use length <- bind(length_generator)
  list_with_length_from(element_generator, length)
}

/// `list_with_length_from(element_generator, length)` generates lists of 
/// elements from `element_generator` of length `length`.
/// 
pub fn list_with_length_from(
  element_generator element_generator: Generator(a),
  length length: Int,
) -> Generator(List(a)) {
  use seed <- Generator
  list_generic_loop(length, tree.return([]), element_generator, seed)
}

// MARK: Dicts

/// `dict_generic(key_generator, value_generator, length_generator)` generates 
/// dictionaries with keys
/// from `key_generator`, values from `value_generator`, and sizes from 
/// `size_generator`.
/// 
/// Shrinks on size then on elements.
/// 
/// Note: If the size generator generates a size of 5 for an example, then for
/// that example `5` is taken as the upper bound on the size of the 
/// dictionary.
/// The current implementation will generate 5 key-value pairs, but it does NOT
/// guarantee that each of the 5 keys is unique.  So, depending on your
/// `key_generator`, the actual size may be less than 5.  (This is considered
/// to be an implementation detail that you should not rely upon.)
/// 
pub fn dict_generic(
  key_generator key_generator: Generator(key),
  value_generator value_generator: Generator(value),
  size_generator size_generator: Generator(Int),
) -> Generator(Dict(key, value)) {
  use association_list <- map(list_generic(
    element_generator: tuple2(key_generator, value_generator),
    length_generator: size_generator,
  ))
  dict.from_list(association_list)
}

// MARK: Sets

/// `set_generic(element_generator, max_len)` generates sets of elements from 
/// `element_generator`.
/// 
/// Shrinks first on the number of elements, then on the elements themselves.
/// 
/// Note: If the size generator generates a size of 5 for an example, then for
/// that example `5` is taken as the upper bound on the size of the 
/// set.
/// The current implementation will generate 5 key-value pairs, but it does NOT
/// guarantee that each of the 5 keys is unique.  So, depending on your
/// `element_generator`, the actual size may be less than 5.  (This is 
/// considered
/// to be an implementation detail that you should not rely upon.)
/// 
pub fn set_generic(
  element_generator element_generator: Generator(a),
  size_generator size_generator: Generator(Int),
) -> Generator(set.Set(a)) {
  use elements <- map(list_generic(
    element_generator:,
    length_generator: size_generator,
  ))
  set.from_list(elements)
}

// MARK: Other

type GenerateOption {
  GenerateNone
  GenerateSome
}

fn generate_option() -> random.Generator(GenerateOption) {
  random.weighted(#(15, GenerateNone), [#(85, GenerateSome)])
}

/// `option(gen)` is an `Option` generator that uses `gen` to generate `Some` 
/// values.  Shrinks towards `None` then towards shrinks of `gen`.
/// 
pub fn option(generator: Generator(a)) -> Generator(Option(a)) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(generate_option, seed) = random.step(generate_option(), seed)

    case generate_option {
      GenerateNone -> #(tree.return(None), seed)
      GenerateSome -> {
        let #(tree, seed) = generate(seed)

        #(tree.option(tree), seed)
      }
    }
  })
}

/// `nil()` is the `Nil` generator. It always returns `Nil` and does not shrink.
/// 
pub fn nil() -> Generator(Nil) {
  Generator(fn(seed) { #(tree.return(Nil), seed) })
}

/// `bool()` generates booleans and shrinks towards `False`.
/// 
pub fn bool() -> Generator(Bool) {
  Generator(fn(seed) {
    let #(bool, seed) =
      random.choose(True, False)
      |> random.step(seed)

    let tree = case bool {
      True -> Tree(True, yielder.once(fn() { tree.return(False) }))
      False -> tree.return(False)
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

fn failwith(
  original_value original_value: a,
  shrunk_value shrunk_value: a,
  shrink_steps shrink_steps: Int,
  error_msg error_msg: String,
) -> b {
  // If this returned an opaque Exn type then you couldn't mess up the
  // `test_error_message.rescue` call later, but it could potentially conflict
  // with non-gleeunit test frameworks, depending on how they deal with
  // exceptions.

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

fn regexp_first_submatch(
  pattern pattern: String,
  in value: String,
) -> Result(String, String) {
  regexp.from_string(pattern)
  // Convert regexp.CompileError to a String
  |> result.map_error(string.inspect)
  // Apply the regular expression
  |> result.map(regexp.scan(_, value))
  // We should see only a single match
  |> result.then(fn(matches) {
    case matches {
      [match] -> Ok(match)
      _ -> Error("expected exactly one match")
    }
  })
  // We should see only a single successful submatch
  |> result.then(fn(match) {
    let regexp.Match(_content, submatches) = match

    case submatches {
      [Some(submatch)] -> Ok(submatch)
      _ -> Error("expected exactly one submatch")
    }
  })
}

/// Mainly for asserting values in qcheck internal tests.
/// 
fn test_error_message_get_original_value(
  test_error_str: String,
) -> Result(String, String) {
  regexp_first_submatch(pattern: "original_value: (.+?);", in: test_error_str)
}

/// Mainly for asserting values in qcheck internal tests.
/// 
fn test_error_message_get_shrunk_value(
  test_error_str: String,
) -> Result(String, String) {
  regexp_first_submatch(pattern: "shrunk_value: (.+?);", in: test_error_str)
}

/// Mainly for asserting values in qcheck internal tests.
/// 
fn test_error_message_get_shrink_steps(
  test_error_str: String,
) -> Result(String, String) {
  regexp_first_submatch(pattern: "shrink_steps: (.+?);", in: test_error_str)
}

/// This function should only be called to rescue a function that may call
/// `failwith` at some point to raise an exception.  It will likely 
/// raise otherwise.
/// 
/// This function is internal.  Breaking changes may occur without a major 
/// version update.
/// 
@internal
pub fn rescue(thunk: fn() -> a) -> Result(a, TestErrorMessage) {
  case rescue_error(thunk) {
    Ok(a) -> Ok(a)
    Error(err) -> {
      // If this assert causes a panic, then you have an implementation error.
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
fn rescue_error(f: fn() -> a) -> Result(a, String)

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Try
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

type Try(a) {
  NoPanic(a)
  Panic(exception.Exception)
}

fn try(f: fn() -> a) -> Try(a) {
  case exception.rescue(fn() { f() }) {
    Ok(y) -> NoPanic(y)
    Error(exn) -> Panic(exn)
  }
}

// MARK: Unicode

/// `utf_codepoint()` generates valid Unicode codepoints.
/// 
pub fn utf_codepoint() -> Generator(UtfCodepoint) {
  use int <- map(int_uniform_inclusive(0x0000, 0x10FFFF))
  case int {
    // This is to work around the broken implementation of
    // `string.utf_codepoint` currently in the stdlib.  Once that fix is
    // upstreamed, you should remove this branch.
    n if n == 0xFFFE || n == 0xFFFF -> utf_codepoint_exn(ascii_a_lowercase)
    // [0, 55295]
    n if 0 <= n && n <= 0xD7FF -> utf_codepoint_exn(n)
    // [57344, 1114111], other than 0xFFFE and 0xFFFF.
    n if 0xE000 <= n && n <= 0x10FFFF -> utf_codepoint_exn(n)
    _ -> utf_codepoint_exn(ascii_a_lowercase)
  }
}

fn utf_codepoint_exn(int: Int) -> UtfCodepoint {
  case string.utf_codepoint(int) {
    Ok(cp) -> cp
    Error(Nil) -> panic as { "ERROR utf_codepoint_exn: " <> int.to_string(int) }
  }
}

// MARK: Bit arrays

fn byte() -> Generator(Int) {
  int_uniform_inclusive(0, 255)
}

/// `bit_array_with_size_from(bit_generator, bit_size)` generates bit arrays of 
/// the given number of bits (bit_size) where elements are generated according 
/// to the given `bit_generator`.
///
/// Shrinks on values, not on length.
/// 
pub fn bit_array_with_size_from(
  value_generator value_generator: Generator(Int),
  bit_size bit_size: Int,
) -> Generator(BitArray) {
  use seed <- Generator

  let #(generated_bit_array, int_trees, seed) =
    do_gen_bit_array(value_generator, seed, <<>>, [], bit_size)

  let shrink = fn() {
    let int_list_tree = int_trees |> list.reverse |> tree.sequence_trees

    let Tree(_root, children) =
      tree.map(int_list_tree, value_with_size_list_to_bit_array)

    children
  }

  let tree = Tree(generated_bit_array, shrink())

  #(tree, seed)
}

type ValueWithSize {
  ValueWithSize(int: Int, size: Int)
}

fn value_with_size_list_to_bit_array(
  value_with_size_list: List(ValueWithSize),
) -> BitArray {
  use acc, ValueWithSize(int:, size:) <- list.fold(value_with_size_list, <<>>)
  <<int:size(size), acc:bits>>
}

fn do_gen_bit_array(
  value_generator: Generator(Int),
  seed: Seed,
  acc: BitArray,
  value_with_size_trees: List(Tree(ValueWithSize)),
  k: Int,
) -> #(BitArray, List(Tree(ValueWithSize)), Seed) {
  let Generator(generate) = value_generator
  let #(int_tree, seed) = generate(seed)

  case k {
    k if k <= 0 -> #(acc, value_with_size_trees, seed)
    k if k <= 8 -> {
      let value_with_size_tree =
        tree.map(int_tree, fn(int) { ValueWithSize(int:, size: k) })

      let Tree(ValueWithSize(int: root, size: _), _) = value_with_size_tree

      do_gen_bit_array(
        value_generator,
        seed,
        <<root:size(k), acc:bits>>,
        [value_with_size_tree, ..value_with_size_trees],
        0,
      )
    }
    k -> {
      let value_with_size_tree =
        tree.map(int_tree, fn(int) { ValueWithSize(int:, size: 8) })

      let Tree(ValueWithSize(int: root, size: _), _) = value_with_size_tree

      do_gen_bit_array(
        value_generator,
        seed,
        <<root, acc:bits>>,
        [value_with_size_tree, ..value_with_size_trees],
        k - 8,
      )
    }
  }
}

/// `bit_array_generic(value_generator, bit_size_generator)` generates bit_arrays with 
/// characters from `value_generator` and lengths from `bit_size_generator`.
/// 
pub fn bit_array_generic(
  value_generator value_generator: Generator(Int),
  bit_size_generator bit_size_generator: Generator(Int),
) -> Generator(BitArray) {
  bit_size_generator |> bind(bit_array_with_size_from(value_generator, _))
}

/// `bit_array()` generates `BitArrays`.
/// 
/// Note: This function will generate bit arrays that cause runtime crashes when 
/// targeting JavaScript.
/// 
pub fn bit_array() -> Generator(BitArray) {
  bit_array_generic(
    value_generator: byte(),
    bit_size_generator: int_small_positive_or_zero(),
  )
}

/// `bit_array()` generates non-empty `BitArrays`.
/// 
/// Note: This function will generate bit arrays that cause runtime crashes when 
/// targeting JavaScript.
/// 
pub fn bit_array_non_empty() -> Generator(BitArray) {
  bit_array_generic(
    value_generator: byte(),
    bit_size_generator: int_small_strictly_positive(),
  )
}

/// `bit_array_with_size(size)` generates `BitArrays` of the given `size`.
/// 
/// Note:
/// - If `size > 1023`, then size will be `1023`.
/// - If `size < 0`, then size will be `0`.
/// 
/// Note: This function will generate bit arrays that cause runtime crashes when 
/// targeting JavaScript, since the JS target only supports byte aligned bit 
/// arrays. TODO this note needs to go on all the ones that don't work on JS
/// 
pub fn bit_array_with_size(size: Int) -> Generator(BitArray) {
  bit_array_with_size_from(byte(), size)
}

// MARK: Bit arrays (UTF-8)

/// `bit_array_utf8()` generates `BitArrays` of valid UTF-8 bytes.
/// 
pub fn bit_array_utf8() -> Generator(BitArray) {
  use max_length <- bind(int_small_strictly_positive())
  use codepoints <- map(utf_codepoint_list(0, max_length))

  bit_array_from_codepoints(codepoints)
}

/// `bit_array_utf8()` generates non-empty `BitArrays` of valid UTF-8
/// bytes.
/// 
pub fn bit_array_utf8_non_empty() -> Generator(BitArray) {
  use max_length <- bind(int_small_strictly_positive())
  use codepoints <- map(utf_codepoint_list(1, max_length))

  bit_array_from_codepoints(codepoints)
}

/// `bit_array_utf8_with_size(num_codepoints)` generates non-empty `BitArrays` 
/// of valid UTF-8 bytes.  
/// 
/// The "size" specified by `num_codepoints` is the number of codepoints 
/// represented by the generated `BitArray` rather than the number of bits or 
/// bytes.
/// 
pub fn bit_array_utf8_with_size(num_codepoints: Int) -> Generator(BitArray) {
  let num_codepoints = ensure_positive_or_zero(num_codepoints)

  use codepoints <- map(utf_codepoint_list(num_codepoints, num_codepoints))

  bit_array_from_codepoints(codepoints)
}

fn utf_codepoint_list(
  min_length: Int,
  max_length: Int,
) -> Generator(List(UtfCodepoint)) {
  list_generic(
    element_generator: utf_codepoint(),
    length_generator: int_uniform_inclusive(min_length, max_length),
  )
}

/// `bit_array_utf8_with_size_from(num_codepoints_generator)` generates 
/// non-empty `BitArrays` of valid UTF-8 bytes.  
/// 
/// The "size" distribution is specified by `num_codepoints_generator` and
/// represents the number of codepoints rather than the number of bits or 
/// bytes.
/// 
pub fn bit_array_utf8_with_size_from(
  codepoint_generator codepoint_generator: Generator(UtfCodepoint),
  num_codepoints num_codepoints: Int,
) -> Generator(BitArray) {
  use codepoints <- map(list_with_length_from(
    element_generator: codepoint_generator,
    length: num_codepoints,
  ))

  bit_array_from_codepoints(codepoints)
}

pub fn bit_array_utf8_generic(
  codepoint_generator codepoint_generator: Generator(UtfCodepoint),
  num_codepoints_generator num_codepoints_generator: Generator(Int),
) {
  use length <- map(num_codepoints_generator)
  list_with_length_from(codepoint_generator, length)
}

fn bit_array_from_codepoints(codepoints: List(UtfCodepoint)) -> BitArray {
  codepoints
  |> string.from_utf_codepoints()
  |> bit_array.from_string()
}

// MARK: Bit arrays (byte-aligned)

/// `bit_array_byte_aligned()` generates byte-aligned `BitArrays`.
/// 
pub fn bit_array_byte_aligned() -> Generator(BitArray) {
  bit_array_generic(
    value_generator: byte(),
    bit_size_generator: byte_aligned_bit_size_generator(0),
  )
}

/// `bit_array_byte_aligned_non_empty()` generates byte-aligned `BitArrays`.
/// 
pub fn bit_array_byte_aligned_non_empty() -> Generator(BitArray) {
  bit_array_generic(
    value_generator: byte(),
    bit_size_generator: byte_aligned_bit_size_generator(1),
  )
}

/// `bit_array_byte_aligned_with_size(num_bytes)` generates byte-aligned 
/// `BitArrays` with the given number of bytes.
/// 
/// Note: the `num_bytes` will be adjusted 
/// 
pub fn bit_array_byte_aligned_with_size(num_bytes: Int) -> Generator(BitArray) {
  let num_bits = ensure_positive_or_zero(num_bytes) * 8
  bit_array_with_size(num_bits)
}

/// `bit_array_byte_aligned_with_size_from(num_bytes_generator)` generates 
/// byte-aligned `BitArrays` with number of bytes specified by the given 
/// generator.
/// 
pub fn bit_array_byte_aligned_with_size_from(
  value_generator value_generator: Generator(Int),
  byte_size byte_size: Int,
) -> Generator(BitArray) {
  let bit_size = byte_size * 8
  bit_array_with_size_from(value_generator, bit_size)
}

/// `bit_array_byte_aligned_generic(value_generator, byte_size_generator)` 
/// generates bit_arrays with 
/// values from `value_generator` and lengths from `byte_size_generator`.
/// 
pub fn bit_array_byte_aligned_generic(
  value_generator value_generator: Generator(Int),
  byte_size_generator byte_size_generator: Generator(Int),
) -> Generator(BitArray) {
  use byte_size <- bind(byte_size_generator)
  bit_array_byte_aligned_with_size_from(value_generator, byte_size)
}

/// Generate a number from the sequence `[0, 8, 16, ..., 128]`.
/// 
fn byte_aligned_bit_size_generator(min: Int) -> Generator(Int) {
  use num_bytes <- map(int_uniform_inclusive(min, 16))
  let num_bits = 8 * num_bytes
  num_bits
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MARK: Utils 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fn list_cons(x, xs) {
  [x, ..xs]
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

/// Convert and int to a single character string.  
/// 
/// If the given int does not 
/// represent a valid codepoint, returns try to convert `default` into a valid 
/// codepoint.
/// 
/// If that too doesn't work, then just return `"a"` -- but you should ensure 
/// that `default` will be a valid codepoint or you may mess up the expected 
/// shrinking behavior.
/// 
fn int_to_char(n: Int, default default: Int) -> String {
  case string.utf_codepoint(n) {
    Ok(cp) -> string.from_utf_codepoints([cp])
    Error(Nil) ->
      case string.utf_codepoint(default) {
        Ok(cp) -> string.from_utf_codepoints([cp])
        Error(Nil) -> "a"
      }
  }
}

/// Return the codepoint representation of the character.
///
/// If the given character is a multicodepoint grapheme cluster, only returns
/// the first codepoint in the cluster.
/// 
fn char_to_int(char: String) -> Int {
  case string.to_utf_codepoints(char) {
    [] -> ascii_a_lowercase
    [codepoint, ..] -> string.utf_codepoint_to_int(codepoint)
  }
}

/// If `n <= 0` return `0`, else return `n`.
fn ensure_positive_or_zero(n: Int) -> Int {
  case int.compare(n, 0) {
    order.Gt | order.Eq -> n
    order.Lt -> 0
  }
}
