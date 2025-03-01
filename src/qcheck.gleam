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
//// ## API
////
//// ### Running Tests
////
//// - [given](#given)
//// - [run](#run)
////
//// ### Configuring and Seeding
////
//// - The [Config](#Config) type
//// - [config](#config)
//// - [default_config](#default_config)
//// - [with_seed](#with_seed)
//// - [with_test_count](#with_test_count)
//// - [with_max_retries](#with_max_retries)
////
//// - The [Seed](#Seed) type
//// - [seed](#seed)
//// - [random_seed](#random_seed)
////
//// ### Low-Level Construction
////
//// - The [Generator](#Generator) type
//// - [generator](#generator)
////
//// ### Combinators and Other Utilities
////
//// - [return](#return) (and [constant](#constant))
//// - [bind](#bind) (and [then](#then))
//// - [apply](#apply)
//// - [parameter](#parameter)
//// - [map](#map)
//// - [map2](#map2)
//// - [map3](#map3)
//// - [map4](#map4)
//// - [map5](#map5)
//// - [map6](#map6)
//// - [from_generators](#from_generators)
//// - [from_weighted_generators](#from_weighted_generators)
//// - [sized_from](#sized_from)
////
//// ### Generator Categories
////
//// There are a few different "categories" of generator.
////
//// - Some types have generators named after the type.
////   - These give a distribution of values that is a reasonable default for test generation.
////   - E.g., `string`, `float`, `bit_array`.
//// - Generic generators
////   - These are fully specified, or "generic", and you must provide generators for values and sizes.
////   - E.g., `generic_string`, `generic_list`.
//// - Fixed size/length generators
////   - These take a size or length parameter as appropriate for the type, and generate values of that size (when possible).
////   - These generators use the default value generator.
////   - E.g., `fixed_length_string`, `fixed_length_list`
//// - Non-empty generators
////   - These generate collections with length or size of at least one
////   - E.g., `non_empty_string`, `non_empty_bit_array`
//// - From other generators
////   - The `_from` suffix means that another generator is used to generate values
////   - E.g., `string_from`, `list_from`
//// - Mixing and matching
////   - Some generators mix and match the above categories
////   - E.g., `fixed_length_list_from`, `non_empty_string_from`
////
//// ### Numeric Generators
////
//// #### Ints
////
//// - [uniform_int](#uniform_int)
//// - [bounded_int](#bounded_int)
//// - [small_non_negative_int](#small_non_negative_int)
//// - [small_strictly_positive_int](#small_strictly_positive_int)
////
//// #### Floats
////
//// - [float](#float)
//// - [bounded_float](#bounded_float)
////
//// ### Codepoint and String Generators
////
//// The main purpose of codepoint generators is to use them to generate
//// strings.
////
//// #### Codepoints
////
//// - [codepoint](#codepoint)
//// - [uniform_codepoint](#uniform_codepoint)
//// - [bounded_codepoint](#bounded_codepoint)
//// - [codepoint_from_ints](#codepoint_from_ints)
//// - [codepoint_from_strings](#codepoint_from_strings)
////
//// ##### ASCII Codepoints
////
//// - [uppercase_ascii_codepoint](#uppercase_ascii_codepoint)
//// - [lowercase_ascii_codepoint](#lowercase_ascii_codepoint)
//// - [ascii_digit_codepoint](#ascii_digit_codepoint)
//// - [alphabetic_ascii_codepoint](#alphabetic_ascii_codepoint)
//// - [alphanumeric_ascii_codepoint](#alphanumeric_ascii_codepoint)
//// - [printable_ascii_codepoint](#printable_ascii_codepoint)
//// - [ascii_whitespace_codepoint](#ascii_whitespace_codepoint)
//// - [uniform_printable_ascii_codepoint](#uniform_printable_ascii_codepoint)
////
//// #### Strings
////
//// String generators are built from codepoint generators.
////
//// - [string](#string)
//// - [string_from](#string_from)
//// - [non_empty_string](#non_empty_string)
//// - [non_empty_string_from](#non_empty_string_from)
//// - [generic_string](#generic_string)
//// - [fixed_length_string_from](#fixed_length_string_from)
////
//// ### Bit Array Generators
////
//// Bit array values come from integers, and handle sizes and shrinking in a
//// reasonable way given that values in the bit array are connected to the
//// size of the bit array in certain situations.
////
//// These functions will generate bit arrays that cause runtime crashes when
//// targeting JavaScript.
////
//// - [bit_array](#bit_array)
//// - [non_empty_bit_array](#non_empty_bit_array)
//// - [fixed_size_bit_array](#fixed_size_bit_array)
//// - [fixed_size_bit_array_from](#fixed_size_bit_array_from)
//// - [generic_bit_array](#generic_bit_array)
////
//// #### Byte-aligned bit arrays
////
//// Byte-aligned bit arrays always have a size that is a multiple of 8.
////
//// These bit arrays work on the JavaScript target.
////
//// - [byte_aligned_bit_array](#byte_aligned_bit_array)
//// - [non_empty_byte_aligned_bit_array](#non_empty_byte_aligned_bit_array)
//// - [fixed_size_byte_aligned_bit_array](#fixed_size_byte_aligned_bit_array)
//// - [fixed_size_byte_aligned_bit_array_from](#fixed_size_byte_aligned_bit_array_from)
//// - [generic_byte_aligned_bit_array](#generic_byte_aligned_bit_array)
////
//// #### UTF-8 Encoded Bit Arrays
////
//// Bit arrays where the values are always valid utf-8 encoded bytes.
////
//// These bit arrays work on the JavaScript target.
////
//// - [utf8_bit_array](#utf8_bit_array)
//// - [non_empty_utf8_bit_array](#non_empty_utf8_bit_array)
//// - [fixed_size_utf8_bit_array](#fixed_size_utf8_bit_array)
//// - [fixed_size_utf8_bit_array_from](#fixed_size_utf8_bit_array_from)
//// - [generic_utf8_bit_array](#generic_utf8_bit_array)
////
//// ### Collection Generators
////
//// #### Lists
////
//// - [list_from](#list_from)
//// - [fixed_length_list_from](#fixed_length_list_from)
//// - [generic_list](#generic_list)
////
//// #### Dictionaries
////
//// - [generic_dict](#generic_dict)
////
//// #### Sets
////
//// - [generic_set](#generic_set)
////
//// #### Tuples
////
//// - [tuple2](#tuple2)
//// - [tuple3](#tuple3)
//// - [tuple4](#tuple4)
//// - [tuple5](#tuple5)
//// - [tuple6](#tuple6)
////
//// ### Other Generators
////
//// - [bool](#bool)
//// - [nil](#nil)
//// - [option_from](#option_from)
////
//// ### Debug Generators
////
//// These functions aren't meant to be used directly in your tests.  They are
//// provided to help debug or investigate what values and shrinks that a
//// generator produces.
////
//// - [generate](#generate)
//// - [generate_tree](#generate_tree)
////
//// ## Notes
////
//// The exact distributions of individual generators are considered an
//// implementation detail, and may change without a major version update.
//// For example, if the `option` generator currently produced `None`
//// approximately 25% of the time, but that distribution was changed to produce
//// `None` 50% of the time instead, that would _not_ be considered a breaking
//// change.
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
import gleam/set
import gleam/string
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

// MARK: Running tests

/// Test a property against generated test cases using the provided
/// configuration.
///
/// ### Arguments
///
/// - `config`: Settings for test execution
/// - `generator`: Creates test inputs
/// - `property`: The property to verify
///
/// ### Returns
///
/// - `Nil` if all test cases pass (the property returns `Nil`)
/// - Panics if any test case fails (the property panics)
///
pub fn run(
  config: Config,
  generator: Generator(a),
  property: fn(a) -> Nil,
) -> Nil {
  do_run(config, generator, property, 0)
}

/// Test a property against generated test cases using the default
/// configuration.
///
/// ### Arguments
///
/// - `generator`: Creates test inputs
/// - `property`: The property to verify
///
/// ### Returns
///
/// - `Nil` if all test cases pass (the property returns `Nil`)
/// - Panics if any test case fails (the property panics)
///
pub fn given(generator: Generator(a), property: fn(a) -> Nil) -> Nil {
  run(default_config(), generator, property)
}

fn do_run(
  config: Config,
  generator: Generator(a),
  property: fn(a) -> Nil,
  i: Int,
) -> Nil {
  case i >= config.test_count {
    True -> Nil
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(config.seed)
      let Tree(value, _shrinks) = tree

      case try(fn() { property(value) }) {
        NoPanic(Nil) -> {
          do_run(config |> with_seed(seed), generator, property, i + 1)
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

type RunPropertyResult {
  RunPropertyOk
  RunPropertyFail
}

// Retrying a test can be useful when when testing non-deterministic code.
// See QCheck2.run_law for more info.
fn run_property(
  property: fn(a) -> Nil,
  value: a,
  max_retries: Int,
) -> RunPropertyResult {
  do_run_property(property, value, max_retries, 0)
}

fn do_run_property(
  property: fn(a) -> Nil,
  value: a,
  max_retries: Int,
  i: Int,
) -> RunPropertyResult {
  case i < max_retries {
    True -> {
      case try(fn() { property(value) }) {
        NoPanic(Nil) -> do_run_property(property, value, max_retries, i + 1)
        Panic(_) -> RunPropertyFail
      }
    }
    False -> RunPropertyOk
  }
}

fn shrink(
  tree: Tree(a),
  property: fn(a) -> Nil,
  run_property_max_retries run_property_max_retries: Int,
) -> #(a, Int) {
  do_shrink(tree, property, run_property_max_retries, 0)
}

fn do_shrink(
  tree: Tree(a),
  property: fn(a) -> Nil,
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

// MARK: Seeds

/// A type representing a seed value used to initialize random generators.
///
pub type Seed =
  random.Seed

/// Create a new seed from a provided integer.
///
/// ### Arguments
///
/// - `n`: Integer to create the seed from
///
/// ### Returns
///
/// A `Seed` value that can be used to configure deterministic test generation
///
/// ### Example
///
/// ```
/// let config = default_config() |> with_seed(seed(124))
/// ```
///
pub fn seed(n: Int) -> Seed {
  random.seed(n)
}

/// Create a new randomly-generated seed.
///
/// ### Returns
///
/// A `Seed` value that can be used to configure non-deterministic test generation
///
/// ### Example
///
/// ```
/// let config = config(test_count: 10_000, max_retries: 1, seed: random_seed())
/// ```
///
pub fn random_seed() -> Seed {
  random.random_seed()
}

// MARK: Test config

/// Configuration for the property-based testing.
///
pub opaque type Config {
  Config(test_count: Int, max_retries: Int, seed: Seed)
}

const default_test_count: Int = 1000

const default_max_retries: Int = 1

/// Create a default configuration for property-based testing.
///
/// ### Returns
///
/// - A `Config` with default settings for test count, max retries, and seed
///
/// ### Example
///
/// ```
/// let config = default_config()
/// ```
///
pub fn default_config() -> Config {
  Config(
    test_count: default_test_count,
    max_retries: default_max_retries,
    seed: random_seed(),
  )
}

/// Create a new `Config` with specified test count, max retries, and seed.
///
/// ### Arguments
///
/// - `test_count`: Number of test cases to generate
/// - `max_retries`: Maximum retries to test a shrunk input candidate.
///      Values > 1 can be useful for testing non-deterministic code.
/// - `seed`: Random seed for deterministic test generation
///
/// ### Returns
///
/// A `Config` with the provided settings, using defaults for any invalid arguments
///
/// ### Example
///
/// ```
/// let config = config(test_count: 10_000, max_retries: 1, seed: seed(47))
/// ```
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

/// Set the number of test cases to run in a property test.
///
/// ### Arguments
///
/// - `config`: The current configuration
/// - `test_count`: Number of test cases to generate.  If `test_count <= 0`,
///     uses the default test count.
///
/// ### Returns
///
/// A new `Config` with the specified test count
///
/// ### Example
///
/// ```
/// let config = default_config() |> with_test_count(10_000)
/// ```
///
pub fn with_test_count(config: Config, test_count: Int) -> Config {
  let test_count = case test_count <= 0 {
    True -> default_test_count
    False -> test_count
  }

  Config(..config, test_count: test_count)
}

/// Set the maximum number of retries for a property test.
///
/// ### Arguments
///
/// - `config`: The current configuration
/// - `max_retries`: Maximum number of retries allowed.  If `max_retries < 0`,
///     uses the default max retries.
///
/// ### Returns
///
/// A new `Config` with the specified maximum retries
///
/// ### Example
///
/// ```
/// let config = default_config() |> with_max_retries(100)
/// ```
///
pub fn with_max_retries(config: Config, max_retries: Int) -> Config {
  let max_retries = case max_retries < 0 {
    True -> default_max_retries
    False -> max_retries
  }

  Config(..config, max_retries: max_retries)
}

/// Set the random seed for reproducible test case generation.
///
/// ### Arguments
///
/// - `config`: The current configuration
/// - `seed`: Seed value for random number generation
///
/// ### Returns
///
/// A new `Config` with the specified random seed
///
/// ### Example
///
/// ```
/// let config = default_config() |> with_seed(seed(124))
/// ```
///
pub fn with_seed(config: Config, seed: Seed) -> Config {
  Config(..config, seed: seed)
}

// MARK: Generators

/// A generator for producing random values of type `a`.
///
/// While the type is not opaque, it's recommended to use the provided
/// generators, and the provided combinators like `map` and `bind`.  Direct
/// generator construction should be reserved for special use-cases.
///
pub type Generator(a) {
  Generator(fn(Seed) -> #(Tree(a), Seed))
}

/// Create a new generator from a random generator and a shrink tree function.
///
/// ### Arguments
///
/// - `random_generator`: Produces random values of type `a`
/// - `tree`: Function that creates a shrink tree for generated values
///
/// ### Returns
///
/// A new `Generator(a)` that combines random generation and shrinking
///
/// ### Notes
///
/// This is a low-level function for building custom generators. Prefer using
/// built-in generators or combinators like `map`, `bind`, etc.
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

/// Generate a fixed number of random values from a generator.
///
/// ### Arguments
///
/// - `generator`: The generator to use for creating values
/// - `number_to_generate`: Number of values to generate
/// - `seed`: Random seed for value generation
///
/// ### Returns
///
/// A list of generated values, without their associated shrinks
///
/// ### Notes
///
/// Primarily useful for debugging generator behavior
///
pub fn generate(
  generator: Generator(a),
  number_to_generate: Int,
  seed: Seed,
) -> #(List(a), Seed) {
  do_gen(generator, number_to_generate, seed, [], 0)
}

fn do_gen(
  generator: Generator(a),
  number_to_generate: Int,
  seed: Seed,
  acc: List(a),
  k: Int,
) -> #(List(a), Seed) {
  case k >= number_to_generate {
    True -> #(acc, seed)
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(seed)
      let Tree(value, _shrinks) = tree
      do_gen(generator, number_to_generate, seed, [value, ..acc], k + 1)
    }
  }
}

/// Generate a single value and its shrink tree from a generator.
///
/// ### Arguments
///
/// - `generator`: The generator to use for creating the value
/// - `seed`: Random seed for value generation
///
/// ### Returns
///
/// A tuple containing the generated value's shrink tree and the next seed
///
/// ### Notes
///
/// Primarily useful for debugging generator behavior
///
pub fn generate_tree(generator: Generator(a), seed: Seed) -> #(Tree(a), Seed) {
  let Generator(generate) = generator

  generate(seed)
}

// MARK: Combinators

/// Create a generator that always returns the same value and does not shrink.
///
/// ### Arguments
///
/// - `a`: The value to be consistently generated
///
/// ### Returns
///
/// A `Generator` that produces the same input for all test cases
///
/// ### Example
///
/// ```
/// use string <- given(return("Gleam"))
/// string == "Gleam"
/// ```
///
pub fn return(a: a) -> Generator(a) {
  Generator(fn(seed) { #(tree.return(a), seed) })
}

/// Create a generator that always returns the same value and does not shrink.
///
/// ### Arguments
///
/// - `a`: The value to be consistently generated
///
/// ### Returns
///
/// A `Generator` that produces the same input for all test cases
///
/// ### Example
///
/// ```
/// use string <- given(constant("Gleam"))
/// string == "Gleam"
/// ```
///
/// ### Notes
///
/// This function is an alias for `return`.
///
pub fn constant(a: a) -> Generator(a) {
  return(a)
}

/// Support for constructing curried functions for the applicative style of
/// generator composition.
///
/// ### Example
///
/// ```
/// type Box {
///   Box(x: Int, y: Int, w: Int, h: Int)
/// }
///
/// fn box_generator() {
///   return({
///     use x <- parameter
///     use y <- parameter
///     use w <- parameter
///     use h <- parameter
///     Box(x:, y:, w:, h:)
///   })
///   |> apply(bounded_int(-100, 100))
///   |> apply(bounded_int(-100, 100))
///   |> apply(bounded_int(1, 100))
///   |> apply(bounded_int(1, 100))
/// }
/// ```
///
pub fn parameter(f: fn(x) -> y) -> fn(x) -> y {
  f
}

/// Transform a generator by applying a function to each generated value.
///
/// ### Arguments
///
/// - `generator`: The original generator to transform
/// - `f`: Function to apply to each generated value
///
/// ### Returns
///
/// A new generator that produces values transformed by `f`, with shrinking
/// behavior derived from the original generator
///
/// ### Examples
///
/// ```
/// let even_number_generator = map(uniform_int(), fn(n) { 2 * n })
/// ```
///
/// With `use`:
///
/// ```
/// let even_number_generator = {
///   use n <- map(uniform_int())
///   2 * n
/// }
/// ```
///
pub fn map(generator: Generator(a), f: fn(a) -> b) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree = tree.map(tree, f)

    #(tree, seed)
  })
}

/// Transform a generator by applying a function that returns another
/// generator to each generated value.
///
/// Unlike `map`, this allows for a dependency on the resulting generator and
/// the original generated values.
///
/// ### Arguments
///
/// - `generator`: A generator that creates a value of type `a`
/// - `f`: A function that takes a value of type `a` and returns a generator
///     of type `b`
///
/// ### Returns
///
/// A generator that first generates a value of type `a`, then uses that value
/// to generate a value of type `b`
///
/// ### Examples
///
/// Say you wanted to generate a valid date in string form, like `"2025-01-30"`.
/// In order to generate a valid day, you need both the month (some months have
/// 31 days, other have fewer) and also the year (since the year affects the max
/// days in February). So, before you can generate a valid day, you must first
/// generate a year and a month. You could imagine a set of functions like this:
///
/// ```
/// fn date_generator() -> Generator(String) {
///   use #(year, month) <- bind(tuple2(year_generator(), month_generator()))
///   use day <- map(day_generator(year:, month:))
///
///   int.to_string(year)
///   <> "-"
///   <> int.to_string(month)
///   <> "-"
///   <> int.to_string(day)
/// }
///
/// // Note how the day generator depends on the value of `year` and `month`.
/// fn day_generator(year year, month month) -> Generator(Int) {
///   todo
/// }
///
/// fn year_generator() -> Generator(Int) {
///   todo
/// }
///
/// fn month_generator() -> Generator(Int) {
///   todo
/// }
/// ```
///
/// Another situation in which you would need `bind` is if you needed to
/// generate departure and arrival times. We will say a pair of departure and
/// arrival times is valid if the departure time is before the arrival time.
/// That means we cannot generate an arrival time without first generating a
/// departure time. Here is how that might look:
///
/// ```
/// fn departure_and_arrival_generator() {
///   use departure_time <- bind(departure_time_generator())
///   use arrival_time <- map(arrival_time_generator(departure_time))
///   #(departure_time, arrival_time)
/// }
///
/// fn departure_time_generator() {
///   todo
/// }
///
/// fn arrival_time_generator(departure_time) {
///   todo
/// }
/// ```
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

/// Transform a generator by applying a function that returns another
/// generator to each generated value.
///
/// Unlike `map`, this allows for a dependency on the resulting generator and
/// the original generated values.
///
/// (`then` is an alias for `bind`.)
///
/// ### Arguments
///
/// - `generator`: A generator that creates a value of type `a`
/// - `f`: A function that takes a value of type `a` and returns a generator
///     of type `b`
///
/// ### Returns
///
/// A generator that first generates a value of type `a`, then uses that value
/// to generate a value of type `b`
///
/// ### Examples
///
/// Say you wanted to generate a valid date in string form, like `"2025-01-30"`.
/// In order to generate a valid day, you need both the month (some months have
/// 31 days, other have fewer) and also the year (since the year affects the max
/// days in February). So, before you can generate a valid day, you must first
/// generate a year and a month. You could imagine a set of functions like this:
///
/// ```
/// fn date_generator() -> Generator(String) {
///   use #(year, month) <- then(tuple2(year_generator(), month_generator()))
///   use day <- map(day_generator(year:, month:))
///
///   int.to_string(year)
///   <> "-"
///   <> int.to_string(month)
///   <> "-"
///   <> int.to_string(day)
/// }
///
/// // Note how the day generator depends on the value of `year` and `month`.
/// fn day_generator(year year, month month) -> Generator(Int) {
///   todo
/// }
///
/// fn year_generator() -> Generator(Int) {
///   todo
/// }
///
/// fn month_generator() -> Generator(Int) {
///   todo
/// }
/// ```
///
/// Another situation in which you would need `then` is if you needed to
/// generate departure and arrival times. We will say a pair of departure and
/// arrival times is valid if the departure time is before the arrival time.
/// That means we cannot generate an arrival time without first generating a
/// departure time. Here is how that might look:
///
/// ```
/// fn departure_and_arrival_generator() {
///   use departure_time <- then(departure_time_generator())
///   use arrival_time <- map(arrival_time_generator(departure_time))
///   #(departure_time, arrival_time)
/// }
///
/// fn departure_time_generator() {
///   todo
/// }
///
/// fn arrival_time_generator(departure_time) {
///   todo
/// }
/// ```
///
pub fn then(generator: Generator(a), f: fn(a) -> Generator(b)) -> Generator(b) {
  bind(generator, f)
}

/// Support for constructing generators in an applicative style.
///
/// ### Example
///
/// ```
/// type Box {
///   Box(x: Int, y: Int, w: Int, h: Int)
/// }
///
/// fn box_generator() {
///   return({
///     use x <- parameter
///     use y <- parameter
///     use w <- parameter
///     use h <- parameter
///     Box(x:, y:, w:, h:)
///   })
///   |> apply(bounded_int(-100, 100))
///   |> apply(bounded_int(-100, 100))
///   |> apply(bounded_int(1, 100))
///   |> apply(bounded_int(1, 100))
/// }
/// ```
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

/// Transform two generators by applying a function to their generated values.
///
/// ### Arguments
///
/// - `g1`: First generator to provide input
/// - `g2`: Second generator to provide input
/// - `f`: Function to apply to generated values from `g1` and `g2`
///
/// ### Returns
///
/// A new generator that produces values by applying `f` to values from `g1`
/// and `g2`
///
/// ### Example
///
/// ```
/// use year, month <- map2(bounded_int(0, 9999), bounded_int(1, 12))
/// int.to_string(year) <> "-" <> int.to_string(month)
/// ```
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

/// Transform three generators by applying a function to their generated values.
///
/// See docs for [`map2`](#map2).
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

/// Transform four generators by applying a function to their generated values.
///
/// See docs for [`map2`](#map2).
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

/// Transform five generators by applying a function to their generated values.
///
/// See docs for [`map2`](#map2).
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

/// Transform six generators by applying a function to their generated values.
///
/// See docs for [`map2`](#map2).
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

/// Generate a tuple of two values using the provided generators.
///
/// ### Arguments
///
/// - `g1`: Generator for the first tuple element
/// - `g2`: Generator for the second tuple element
///
/// ### Returns
///
/// A generator that produces a tuple of two values, one from each input
/// generator
///
/// ### Example
///
/// ```
/// let point_generator = tuple2(float(), float())
/// ```
///
pub fn tuple2(g1: Generator(x1), g2: Generator(x2)) -> Generator(#(x1, x2)) {
  use x1, x2 <- map2(g1, g2)
  #(x1, x2)
}

/// Generate a tuple of three values using the provided generators.
///
/// See docs for [`tuple2`](#tuple2).
///
pub fn tuple3(
  g1: Generator(x1),
  g2: Generator(x2),
  g3: Generator(x3),
) -> Generator(#(x1, x2, x3)) {
  use x1, x2, x3 <- map3(g1, g2, g3)
  #(x1, x2, x3)
}

/// Generate a tuple of four values using the provided generators.
///
/// See docs for [`tuple2`](#tuple2).
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

/// Generate a tuple of five values using the provided generators.
///
/// See docs for [`tuple2`](#tuple2).
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

/// Generate a tuple of six values using the provided generators.
///
/// See docs for [`tuple2`](#tuple2).
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

/// Choose a generator from a list of generators, then generate a value from
/// the selected generator.
///
/// ### Arguments
///
/// - `generator`: Initial generator to include in the choice
/// - `generators`: Additional generators to choose from
///
/// ### Returns
///
/// A generator that selects and uses one of the provided generators
///
/// ### Notes
///
/// - Will always produce values since at least one generator is required
///
/// ### Example
///
/// ```
/// fn mostly_ascii_characters_generator() {
///   from_generators(uppercase_ascii_codepoint(), [
///     lowercase_ascii_codepoint(),
///     uniform_codepoint(),
///   ])
/// }
/// ```
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

/// Choose a generator from a list of weighted generators, then generate a
/// value from the selected generator.
///
/// ### Arguments
///
/// - `generator`: Initial weighted generator (weight and generator)
/// - `generators`: Additional weighted generators
///
/// ### Returns
///
/// A generator that selects and generates values based on the provided
/// weights
///
/// ### Example
///
/// ```
/// from_weighted_generators(#(26, uppercase_ascii_codepoint()), [
///   #(26, lowercase_ascii_codepoint()),
///   #(10, ascii_digit_codepoint()),
/// ])
/// ```
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

/// Creates a generator by first generating a size using the provided
/// `size_generator`, then passing that size to the `sized_generator` to
/// produce a value.
///
/// Shrinks on the size first, then on the generator.
///
/// ### Arguments
///
/// - `sized_generator`: A generator function that takes a size and produces a
///     value
/// - `size_generator`: A generator for creating the size input
///
/// ### Returns
///
/// A generator that first produces a size, then uses that size to generate a
/// value
///
/// ### Example
///
/// Create a bit arrays whose bit size is from 10 to 20.
///
/// ```
/// fixed_size_bit_array() |> sized_from(bounded_int(10, 20))
/// ```
///
pub fn sized_from(
  sized_generator: SizedGenerator(a),
  size_generator: Generator(Int),
) -> Generator(a) {
  size_generator |> bind(sized_generator)
}

// MARK: Ints

/// Generate small non-negative integers, well-suited for modeling sized
/// elements like lists or strings.
///
/// Shrinks towards `0`.
///
/// ### Returns
///
/// A generator for small, non-negative integers
///
/// ### Example
///
/// ```
/// generic_string(bounded_codepoint(0, 255), small_non_negative_int())
/// ```
///
pub fn small_non_negative_int() -> Generator(Int) {
  generator(
    random.int(0, 100)
      |> random.then(fn(x) {
        case x < 75 {
          True -> random.int(0, 10)
          False -> random.int(0, 100)
        }
      }),
    fn(n) { tree.new(n, shrink.int_towards(0)) },
  )
}

/// Generate small, strictly positive integers, well-suited for modeling sized
/// elements like lists or strings.
///
/// Shrinks towards `0`.
///
/// ### Returns
///
/// A generator for small, strictly positive integers
///
/// ### Example
///
/// ```
/// generic_string(bounded_codepoint(0, 255), small_strictly_positive_int())
/// ```
///
pub fn small_strictly_positive_int() -> Generator(Int) {
  small_non_negative_int() |> map(int.add(_, 1))
}

/// Generate integers uniformly distributed between `from` and `to`, inclusive.
///
/// ### Arguments
///
/// - `from`: Lower bound of the range (inclusive)
/// - `to`: Upper bound of the range (inclusive)
///
/// ### Returns
///
/// A generator producing integers within the specified range.
///
/// ### Behavior
///
/// - Shrinks towards `0`, but won't shrink outside of the range `[from, to]`
/// - Automatically orders parameters if `from` > `to`
///
/// ### Example
///
/// Generate integers between -10 and 10.
///
/// ```
/// bounded_int(-10, 10)
/// ```
///
pub fn bounded_int(from low: Int, to high: Int) -> Generator(Int) {
  let #(low, high) = case low <= high {
    True -> #(low, high)
    False -> #(high, low)
  }

  generator(random.int(low, high), fn(n) {
    let origin = pick_origin_within_range(low, high, goal: 0)

    tree.new(n, shrink.int_towards(origin))
  })
}

// This is only used to ensure that codepoint generators shrink to "a" if possible.
fn bounded_int_with_shrink_target(
  from low: Int,
  to high: Int,
  shrink_target shrink_target: Int,
) -> Generator(Int) {
  let #(low, high) = case low <= high {
    True -> #(low, high)
    False -> #(high, low)
  }

  generator(random.int(low, high), fn(n) {
    let origin = pick_origin_within_range(low, high, goal: shrink_target)

    tree.new(n, shrink.int_towards(origin))
  })
}

/// Generate uniformly distributed integers across a large range.
///
/// ### Details
///
/// - Shrinks generated values towards `0`
/// - Not likely to hit interesting or corner cases
///
/// ### Returns
///
/// A generator of integers with uniform distribution
///
/// ### Example
///
/// ```
/// let positive_int_generator = {
///   use n <- map(uniform_int())
///   int.absolute_value(n)
/// }
/// ```
///
pub fn uniform_int() -> Generator(Int) {
  bounded_int(random.min_int, random.max_int)
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

/// Generate floats with a bias towards smaller values.
///
/// Shrinks towards `0.0`.
///
/// ### Returns
///
/// A generator that produces floating-point numbers
///
pub fn float() -> Generator(Float) {
  Generator(fn(seed) {
    let #(x, seed) = random.float(0.0, 15.0) |> random.step(seed)
    let #(y, seed) = random.choose(1.0, -1.0) |> random.step(seed)
    let #(z, seed) = random.choose(1.0, -1.0) |> random.step(seed)

    // The QCheck2.Gen.float code has this double multiply in it. Actually not
    // sure about that.
    let generated_value = exp(x) *. y *. z

    let tree = tree.new(generated_value, shrink.float_towards(0.0))

    #(tree, seed)
  })
}

/// Generate floats uniformly distributed between `from` and `to`, inclusive.
///
/// ### Arguments
///
/// - `from`: Lower bound of the range (inclusive)
/// - `to`: Upper bound of the range (inclusive)
///
/// ### Returns
///
/// A generator producing floats within the specified range.
///
/// ### Behavior
///
/// - Shrinks towards `0`, but won't shrink outside of the range `[from, to]`
/// - Automatically orders parameters if `from` > `to`
///
/// ### Example
///
/// Generate floats between -10 and 10.
///
/// ```
/// bounded_float(-10, 10)
/// ```
pub fn bounded_float(from low: Float, to high: Float) {
  let #(low, high) = case low <=. high {
    True -> #(low, high)
    False -> #(high, low)
  }

  generator(random.float(low, high), fn(n) {
    let origin = pick_origin_within_range_float(low, high, goal: 0.0)

    tree.new(n, shrink.float_towards(origin))
  })
}

// MARK: Codepoints

/// Generate Unicode codepoints uniformly distributed within a specified
/// range.
///
/// ### Arguments
///
/// - `from`: Minimum codepoint value (inclusive)
/// - `to`: Maximum codepoint value (inclusive)
///
/// ### Returns
///
/// A generator that produces Unicode codepoints within the specified range.
///
/// ### Notes
///
/// - If the range is invalid, it will be automatically adjusted to a valid
///   range
/// - Shrinks towards an origin codepoint (typically lowercase 'a')
/// - Mainly used for string generation
///
/// ### Example
///
/// ```
/// let cyrillic_character = bounded_codepoint(from: 0x0400, to: 0x04FF)
/// ```
///
pub fn bounded_codepoint(from low: Int, to high: Int) -> Generator(UtfCodepoint) {
  let #(low, high) = case low <= high {
    True -> #(low, high)
    False -> #(high, low)
  }

  // It is okay if the min and max are the same.
  let low = int.clamp(low, min: min_valid_codepoint, max: max_valid_codepoint)
  let high = int.clamp(high, min: min_valid_codepoint, max: max_valid_codepoint)

  let origin = pick_origin_within_range(low, high, goal: ascii_a_lowercase)
  let shrink = shrink.int_towards(origin)

  use seed <- Generator
  let #(n, seed) = random.int(low, high) |> random.step(seed)

  let tree =
    tree.new(n, shrink)
    // If user crafts a range that generates lots of invalid codepoints, then
    // the nice shrinking will get a bit weird.  But origin should be valid
    // unless there is an implementation error, since the "goal" above should
    // always be valid.
    |> tree.map(int_to_codepoint(_, on_error: origin))

  #(tree, seed)
}

/// Generate Unicode codepoints.
///
/// ### Returns
///
/// A generator that creates Unicode codepoints across the valid range
///
/// ### Notes
///
/// - Generates codepoints from U+0000 to U+10FFFF
/// - Uses ASCII lowercase 'a' as a shrink target
///
/// ### Example
///
/// ```
/// string_from(uniform_codepoint())
/// ```
///
pub fn uniform_codepoint() -> Generator(UtfCodepoint) {
  use int <- map(bounded_int_with_shrink_target(
    from: 0x0000,
    to: 0x10FFFF,
    shrink_target: ascii_a_lowercase,
  ))
  case int {
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

/// Generate uppercase ASCII letters.
///
/// ### Returns
///
/// A generator that produces uppercase letters from `A` to `Z` as codepoints
///
/// ### Example
///
/// ```
/// string_from(uppercase_ascii_codepoint())
/// ```
///
pub fn uppercase_ascii_codepoint() -> Generator(UtfCodepoint) {
  bounded_codepoint(from: ascii_a_uppercase, to: ascii_z_uppercase)
}

/// Generate lowercase ASCII letters.
///
/// ### Returns
///
/// A generator that produces lowercase letters from `a` to `z` as codepoints
///
/// ### Example
///
/// ```
/// string_from(lowercase_ascii_codepoint())
/// ```
///
pub fn lowercase_ascii_codepoint() -> Generator(UtfCodepoint) {
  bounded_codepoint(from: ascii_a_lowercase, to: ascii_z_lowercase)
}

/// Generate ASCII digits as codepoints.
///
/// ### Returns
///
/// A generator that produces ASCII digits from `0` to `9` as codepoints
///
/// ### Example
///
/// ```
/// string_from(ascii_digit_codepoint())
/// ```
///
pub fn ascii_digit_codepoint() -> Generator(UtfCodepoint) {
  bounded_codepoint(from: ascii_zero, to: ascii_nine)
}

/// Generate alphabetic ASCII characters.
///
/// ### Returns
///
/// A generator that produces alphabetic ASCII characters as codepoints
///
/// ### Example
///
/// ```
/// string_from(alphabetic_ascii_codepoint())
/// ```
///
pub fn alphabetic_ascii_codepoint() -> Generator(UtfCodepoint) {
  from_generators(uppercase_ascii_codepoint(), [lowercase_ascii_codepoint()])
}

/// Generate alphanumeric ASCII characters.
///
/// ### Returns
///
/// A generator that produces alphanumeric ASCII characters as codepoints
///
/// ### Example
///
/// ```
/// string_from(alphanumeric_ascii_codepoint())
/// ```
///
pub fn alphanumeric_ascii_codepoint() -> Generator(UtfCodepoint) {
  from_weighted_generators(#(26, uppercase_ascii_codepoint()), [
    #(26, lowercase_ascii_codepoint()),
    #(10, ascii_digit_codepoint()),
  ])
}

/// Uniformly generate printable ASCII characters.
///
/// ### Returns
///
/// A generator that produces printable ASCII characters as codepoints
///
/// ### Example
///
/// ```
/// string_from(uniform_printable_ascii_codepoint())
/// ```
///
pub fn uniform_printable_ascii_codepoint() -> Generator(UtfCodepoint) {
  bounded_codepoint(from: ascii_space, to: ascii_tilde)
}

/// Generate printable ASCII characters with a bias towards alphanumeric
/// characters.
///
/// ### Returns
///
/// A generator that produces printable ASCII characters as codepoints
///
/// ### Example
///
/// ```
/// string_from(printable_ascii_codepoint())
/// ```
///
pub fn printable_ascii_codepoint() -> Generator(UtfCodepoint) {
  from_weighted_generators(#(381, uppercase_ascii_codepoint()), [
    #(381, lowercase_ascii_codepoint()),
    #(147, ascii_digit_codepoint()),
    #(91, uniform_printable_ascii_codepoint()),
  ])
}

/// Generate Unicode codepoints with a decent distribution that is good for
/// generating genreal strings.
///
/// ### Returns
///
/// A generator that produces Unicode codepoints
///
/// ### Example
///
/// The decent default string generator could be writen something like this:
///
/// ```
/// generic_string(codepoint(), small_non_negative_int())
/// ```
///
pub fn codepoint() -> Generator(UtfCodepoint) {
  // The base_quickcheck library has some generation of
  // the min and max char values, which we do not do here.
  from_weighted_generators(#(30, uppercase_ascii_codepoint()), [
    #(30, lowercase_ascii_codepoint()),
    #(10, ascii_digit_codepoint()),
    #(15, uniform_printable_ascii_codepoint()),
    #(15, uniform_codepoint()),
  ])
}

/// Generate a codepoint from a list of codepoints represented as integers.
///
/// Splitting up the arguments in this way ensures some value is always
/// generated by preventing you from passing in an empty list.
///
/// ### Arguments
///
/// - `first`: First codepoint to choose from
/// - `rest`: Additional codepoints to choose from
///
/// ### Returns
///
/// A `Generator` that produces codepoints from the provided values
///
/// ### Example
///
/// ```
/// let ascii_whitespace_generator = codepoint_from_ints(
///   // Horizontal tab
///   9,
///   [
///     // Line feed
///     10,
///     // Vertical tab
///     11,
///     // Form feed
///     12,
///     // Carriage return
///     13,
///     // Space
///     32,
///   ],
/// )
/// ```
///
pub fn codepoint_from_ints(
  first: Int,
  rest: List(Int),
) -> Generator(UtfCodepoint) {
  let hd = first
  let tl = rest

  // Take the char with the minimum int representation as the shrink target.
  let shrink_target = list.fold(tl, hd, int.min)

  use seed <- Generator
  let #(n, seed) = random.uniform(hd, tl) |> random.step(seed)

  let tree =
    tree.new(n, shrink.int_towards(shrink_target))
    |> tree.map(int_to_codepoint(_, on_error: shrink_target))

  #(tree, seed)
}

/// Generate a codepoint from a list of strings.
///
/// ### Arguments
///
/// - `first`: First character to choose from
/// - `rest`: Additional characters to choose from
///
/// ### Returns
///
/// A `Generator` that produces codepoints from the provided values
///
/// ### Notes
///
/// - Splitting up the arguments in this way ensures some value is always
///   generated by preventing you from passing in an empty list.
/// - Only the first codepoint is taken from each of the provided strings
///
/// ### Example
///
/// ```
/// let quadrant_generator = codepoint_from_strings("▙", ["▛", "▜", "▟"])
/// ```
///
pub fn codepoint_from_strings(
  first: String,
  rest: List(String),
) -> Generator(UtfCodepoint) {
  let head = char_to_int(first)
  let tail = list.map(rest, char_to_int)

  codepoint_from_ints(head, tail)
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

/// Generate ASCII whitespace as codepoints.
///
/// ### Returns
///
/// A generator that produces ASCII whitespace as codepoints
///
/// ### Example
///
/// ```
/// let whitespace_generator = string_from(ascii_whitespace_codepoint())
/// ```
///
pub fn ascii_whitespace_codepoint() -> Generator(UtfCodepoint) {
  codepoint_from_ints(
    // Horizontal tab
    9,
    [
      // Line feed
      10,
      // Vertical tab
      11,
      // Form feed
      12,
      // Carriage return
      13,
      // Space
      32,
    ],
  )
}

// MARK: Strings

fn do_gen_string(
  target_length: Int,
  i: Int,
  acc: List(UtfCodepoint),
  codepoint_gen: Generator(UtfCodepoint),
  codepoint_trees_rev: List(Tree(UtfCodepoint)),
  seed: Seed,
) -> #(String, List(Tree(UtfCodepoint)), Seed) {
  let Generator(gen_codepoint_tree) = codepoint_gen

  let #(codepoint_tree, seed) = gen_codepoint_tree(seed)

  case i >= target_length {
    True -> {
      // Here things get a little weird because we could have generated the
      // correct number of codepoints, but the length of the string as reported
      // by stdlib string.legnth is in graphemes, and certain codepoints will
      // combine such that the grapheme length of the string will be <= the
      // number of codepoints in that string. _But_, we don't want to check the
      // string length on every iteration, because that is a slow operation in
      // Gleam. So only check it once we have the potential to be done.
      let generated_string = list.reverse(acc) |> string.from_utf_codepoints

      case string.length(generated_string) < target_length {
        True -> {
          // At least one codepoint has combined with a previous one to create a
          // grapheme that has more than one codepoint. So we need to keep
          // going.

          let Tree(root, _) = codepoint_tree

          do_gen_string(
            target_length,
            i + 1,
            [root, ..acc],
            codepoint_gen,
            [codepoint_tree, ..codepoint_trees_rev],
            seed,
          )
        }
        False -> {
          // The length is what we expect so we're good.
          #(generated_string, codepoint_trees_rev, seed)
        }
      }
    }
    False -> {
      let Tree(root, _) = codepoint_tree

      do_gen_string(
        target_length,
        i + 1,
        [root, ..acc],
        codepoint_gen,
        [codepoint_tree, ..codepoint_trees_rev],
        seed,
      )
    }
  }
}

/// Generate a fixed-length string from the given codepoint generator.
///
/// ### Arguments
///
/// - `generator`: A generator for codepoints
/// - `length`: Number of graphemes in the generated string
///
/// ### Returns
///
/// A generator that produces strings with the specified number of graphemes
///
/// ### Example
///
/// ```
/// fixed_length_string_from(codepoint(), 5)
/// ```
///
pub fn fixed_length_string_from(
  generator: Generator(UtfCodepoint),
  length: Int,
) -> Generator(String) {
  Generator(fn(seed) {
    let #(generated_string, reversed_codepoint_trees, seed) =
      do_gen_string(length, 0, [], generator, [], seed)

    let shrink = fn() {
      let codepoint_list_tree =
        list.reverse(reversed_codepoint_trees) |> tree.sequence_trees

      // Technically `Tree(_root, children)` is the whole tree, but we create it
      // eagerly above.
      let Tree(_root, children) =
        codepoint_list_tree
        |> tree.map(fn(char_list) { string.from_utf_codepoints(char_list) })

      children
    }

    let tree = Tree(generated_string, shrink())

    #(tree, seed)
  })
}

/// Generate a string from the given codepoint generator and the given length
/// generator.
///
/// ### Arguments
///
/// - `codepoint_generator`: A generator for codepoints
/// - `length_generator`: A generator to determine number of graphemes in the
///      generated strings
///
/// ### Returns
///
/// A string generator
///
/// ### Example
///
/// ```
/// generic_string(ascii_digit_codepoint(), bounded_int(8, 15))
/// ```
///
pub fn generic_string(
  codepoints_from codepoint_generator: Generator(UtfCodepoint),
  length_from length_generator: Generator(Int),
) -> Generator(String) {
  use length <- bind(length_generator)
  fixed_length_string_from(codepoint_generator, length)
}

/// Generate strings with the default codepoint and length generators.
///
/// ### Example
///
/// ```
/// use string <- given(string())
/// string.length(string) == string.length(string <> "!") + 1
/// ```
///
pub fn string() -> Generator(String) {
  use length <- bind(small_non_negative_int())
  fixed_length_string_from(codepoint(), length)
}

/// Generate non-empty strings with the default codepoint and length generators.
///
/// ### Example
///
/// ```
/// use string <- given(string())
/// string.length(string) > 0
/// ```
///
pub fn non_empty_string() -> Generator(String) {
  bind(small_strictly_positive_int(), fn(length) {
    fixed_length_string_from(codepoint(), length)
  })
}

/// Generate strings with the given codepoint generator and default length
/// generator.
///
/// ### Example
///
/// ```
/// string_from(ascii_digit_codepoint())
/// ```
///
pub fn string_from(
  codepoint_generator: Generator(UtfCodepoint),
) -> Generator(String) {
  bind(small_non_negative_int(), fn(length) {
    fixed_length_string_from(codepoint_generator, length)
  })
}

/// Generate non-empty strings with the given codepoint generator and default
/// length generator.
///
/// ### Example
///
/// ```
/// non_empty_string_from(alphanumeric_ascii_codepoint())
/// ```
///
pub fn non_empty_string_from(
  codepoint_generator: Generator(UtfCodepoint),
) -> Generator(String) {
  bind(small_strictly_positive_int(), fn(length) {
    fixed_length_string_from(codepoint_generator, length)
  })
}

// MARK: Lists

fn generic_list_loop(
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

      generic_list_loop(
        n - 1,
        tree.map2(tree, acc, list_cons),
        element_generator,
        seed,
      )
    }
  }
}

/// Generate lists with elements from one generator and lengths from another.
///
/// ### Arguments
///
/// - `elements_from`: Generates list elements
/// - `length_from`: Generates list lengths
///
/// ### Returns
///
/// A generator that produces lists with:
/// - Elements from `elements_from`
/// - Lengths from `length_from`
///
/// ### Shrinking
///
/// Shrinks first on list length, then on list elements, ensuring shrunk lists
/// remain within length generator's range.
///
/// ### Example
///
/// ```
/// generic_list(string(), small_non_negative_int())
/// ```
///
pub fn generic_list(
  elements_from element_generator: Generator(a),
  length_from length_generator: Generator(Int),
) -> Generator(List(a)) {
  use length <- bind(length_generator)
  fixed_length_list_from(element_generator, length)
}

/// Generate fixed-length lists with elements from the given generator.
///
/// ### Arguments
///
/// - `element_generator`: Generates list elements
/// - `length`: The length of the generated lists
///
/// ### Returns
///
/// A generator that produces fixed-length lists with elements from the given
/// generator.
///
/// ### Shrinking
///
/// Shrinks first on list length, then on list elements, ensuring shrunk lists
/// remain within length generator's range.
///
/// ### Example
///
/// ```
/// fixed_length_list_from(string(), 5)
/// ```
///
pub fn fixed_length_list_from(
  element_generator: Generator(a),
  length: Int,
) -> Generator(List(a)) {
  use seed <- Generator
  generic_list_loop(length, tree.return([]), element_generator, seed)
}

/// Generate lists with elements from the given generator and the default
/// length generator.
///
/// ### Arguments
///
/// - `element_generator`: Generates list elements
///
/// ### Returns
///
/// A generator that produces lists with elements from the given generator
///
/// ### Shrinking
///
/// Shrinks first on list length, then on list elements.
///
/// ### Example
///
/// ```
/// list_from(string())
/// ```
///
pub fn list_from(element_generator: Generator(a)) -> Generator(List(a)) {
  generic_list(element_generator, small_non_negative_int())
}

// MARK: Dicts

/// Generates dictionaries with keys from a key generator, values from a value
/// generator, and sizes from a size generator.
///
/// ### Arguments
///
/// - `keys_from`: Generator for dictionary keys
/// - `values_from`: Generator for dictionary values
/// - `size_from`: Generator for dictionary size
///
/// ### Returns
///
/// A generator that produces dictionaries
///
/// ### Notes
///
/// - The actual size may be less than the generated size due to potential key
///   duplicates
/// - Shrinks on size first, then on individual elements
///
/// ### Example
///
/// ```
/// generic_dict(
///   key_generator: uniform_int(),
///   value_generator: string(),
///   size_generator: small_strictly_positive_int()
/// )
/// ```
///
pub fn generic_dict(
  keys_from key_generator: Generator(key),
  values_from value_generator: Generator(value),
  size_from size_generator: Generator(Int),
) -> Generator(Dict(key, value)) {
  use association_list <- map(generic_list(
    elements_from: tuple2(key_generator, value_generator),
    length_from: size_generator,
  ))
  dict.from_list(association_list)
}

// MARK: Sets

/// Generates sets with values from an element generator, and sizes from a size
/// generator.
///
/// ### Arguments
///
/// - `elements_from`: Generator for set elements
/// - `size_from`: Generator for set size
///
/// ### Returns
///
/// A generator that produces sets
///
/// ### Notes
///
/// - The actual size may be less than the generated size due to potential
///   duplicates
/// - Shrinks on size first, then on individual elements
///
/// ### Example
///
/// ```
/// generic_set(
///   value_generator: string(),
///   size_generator: small_strictly_positive_int()
/// )
/// ```
///
pub fn generic_set(
  elements_from element_generator: Generator(a),
  size_from size_generator: Generator(Int),
) -> Generator(set.Set(a)) {
  use elements <- map(generic_list(
    elements_from: element_generator,
    length_from: size_generator,
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

/// Create a generator for `Option` values.
///
/// ### Arguments
///
/// - `generator`: Generator for the inner value type
///
/// ### Returns
///
/// A generator that produces `Option` values, shrinking towards `None` first,
/// then towards the shrinks of the input generator
///
/// ### Example
///
/// ```
/// option_from(string())
/// ```
///
pub fn option_from(generator: Generator(a)) -> Generator(Option(a)) {
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

/// Generate a constant `Nil` value.
///
/// ### Returns
///
/// A `Generator` that always returns `Nil` and does not shrink
///
pub fn nil() -> Generator(Nil) {
  Generator(fn(seed) { #(tree.return(Nil), seed) })
}

/// Generate boolean values.
///
/// ### Returns
///
/// A generator that generates boolean values and shrinks towards `False`
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

// MARK: Bit arrays

fn unsigned_byte() -> Generator(Int) {
  bounded_int(0, 255)
}

/// Generate fixed-size bit arrays where elements are generated
/// using the provided integer generator.
///
/// ### Arguments
///
/// - `value_generator`: Generators bit array values
/// - `bit_size`: Number of bits in the generated bit array
///
/// ### Returns
///
/// A generator of fixed-size bit arrays
///
/// ### Notes
///
/// Shrinks on values, not on size
///
/// ### Example
///
/// ```
/// fixed_size_bit_array_from(bounded_int(0, 255), 64)
/// ```
///
/// ### Warning
///
/// This function will generate bit arrays that cause runtime crashes when
/// targeting JavaScript unless the bit size is a multiple of 8.
///
pub fn fixed_size_bit_array_from(
  value_generator: Generator(Int),
  bit_size: Int,
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

/// Generate bit arrays with configurable values and bit sizes.
///
/// ### Arguments
///
/// - `values_from`: Generator for bit array contents
/// - `bit_size_from`: Generator for bit array size
///
/// ### Returns
///
/// A bit array generator
///
/// ### Example
///
/// ```
/// let generator = generic_bit_array(
///   value_generator: bounded_int(0, 255),
///   bit_size_generator: bounded_int(32, 64)
/// )
/// ```
///
/// ### Warning
///
/// This function will generate bit arrays that cause runtime crashes when
/// targeting JavaScript.
///
pub fn generic_bit_array(
  values_from value_generator: Generator(Int),
  bit_size_from bit_size_generator: Generator(Int),
) -> Generator(BitArray) {
  bit_size_generator |> bind(fixed_size_bit_array_from(value_generator, _))
}

/// Generate bit arrays.
///
/// ### Warning
///
/// This function will generate bit arrays that cause runtime crashes when
/// targeting JavaScript.
///
pub fn bit_array() -> Generator(BitArray) {
  generic_bit_array(
    values_from: unsigned_byte(),
    bit_size_from: small_non_negative_int(),
  )
}

/// Generate non-empty bit arrays.
///
/// ### Returns
///
/// A generator of non-empty bit arrays
///
/// ### Warning
///
/// This function will generate bit arrays that cause runtime crashes when
/// targeting JavaScript.
///
pub fn non_empty_bit_array() -> Generator(BitArray) {
  generic_bit_array(
    values_from: unsigned_byte(),
    bit_size_from: small_strictly_positive_int(),
  )
}

/// Generate fixed-size bit arrays.
///
/// ### Warning
///
/// This function will generate bit arrays that cause runtime crashes when
/// targeting JavaScript.
///
pub fn fixed_size_bit_array(size: Int) -> Generator(BitArray) {
  fixed_size_bit_array_from(unsigned_byte(), size)
}

// MARK: Bit arrays (UTF-8)

/// Generate bit arrays of valid UTF-8 bytes.
///
pub fn utf8_bit_array() -> Generator(BitArray) {
  use max_length <- bind(small_strictly_positive_int())
  use codepoints <- map(utf_codepoint_list(0, max_length))

  bit_array_from_codepoints(codepoints)
}

/// Generate non-empty bit arrays of valid UTF-8 bytes.
///
pub fn non_empty_utf8_bit_array() -> Generator(BitArray) {
  use max_length <- bind(small_strictly_positive_int())
  use codepoints <- map(utf_codepoint_list(1, max_length))

  bit_array_from_codepoints(codepoints)
}

/// Generate a fixed-sized bit array of valid UTF-8 encoded bytes with the
/// given number of codepoints.
///
/// ### Arguments
///
/// - `num_codepoints`: The number of Unicode codepoints represented by the
/// generated bit arrays
///
/// ### Returns
///
/// A generator that produces of fixed-sized bit arrays of UTF-8 encoded bytes
///
/// ### Details
///
/// - The size is determined by the number of Unicode codepoints, not bytes or
///   bits.
/// - If a negative number is provided, it is converted to zero.
///
pub fn fixed_size_utf8_bit_array(num_codepoints: Int) -> Generator(BitArray) {
  let num_codepoints = ensure_positive_or_zero(num_codepoints)

  use codepoints <- map(utf_codepoint_list(num_codepoints, num_codepoints))

  bit_array_from_codepoints(codepoints)
}

fn utf_codepoint_list(
  min_length: Int,
  max_length: Int,
) -> Generator(List(UtfCodepoint)) {
  generic_list(
    elements_from: uniform_codepoint(),
    length_from: bounded_int(min_length, max_length),
  )
}

/// Generate a fixed-sized bit array of valid UTF-8 encoded bytes with the
/// given number of codepoints and values generated from the given codepoint
/// generator.
///
/// ### Arguments
///
/// - `codepoint_generator`: Generates the values
/// - `num_codepoints`: The number of Unicode codepoints represented by the
/// generated bit arrays
///
/// ### Returns
///
/// A generator that produces of fixed-sized bit arrays of UTF-8 encoded bytes
///
/// ### Details
///
/// - The size is determined by the number of Unicode codepoints, not bytes or
///   bits.
/// - If a negative number is provided, it is converted to zero.
///
pub fn fixed_size_utf8_bit_array_from(
  codepoint_generator: Generator(UtfCodepoint),
  num_codepoints: Int,
) -> Generator(BitArray) {
  use codepoints <- map(fixed_length_list_from(
    codepoint_generator,
    num_codepoints,
  ))

  bit_array_from_codepoints(codepoints)
}

/// Generate bit arrays of UTF-8 encoded bytes with configurable values
/// and number of codepoints.
///
/// ### Arguments
///
/// - `codepoints_from`: Generates the codepoint values of the resulting
///     bit arrays
/// - `codepoint_size_from`: Generates sizes in number of codepoints represented
///     by the resulting bit arrays
///
/// ### Returns
///
/// A generator of bit arrays of valid UTF-8 encoded bytes
///
pub fn generic_utf8_bit_array(
  codepoints_from codepoint_generator: Generator(UtfCodepoint),
  codepoint_size_from num_codepoints_generator: Generator(Int),
) {
  use length <- map(num_codepoints_generator)
  fixed_length_list_from(codepoint_generator, length)
}

fn bit_array_from_codepoints(codepoints: List(UtfCodepoint)) -> BitArray {
  codepoints
  |> string.from_utf_codepoints()
  |> bit_array.from_string()
}

// MARK: Bit arrays (byte-aligned)

/// Generate byte-aligned bit arrays.
///
pub fn byte_aligned_bit_array() -> Generator(BitArray) {
  generic_bit_array(
    values_from: unsigned_byte(),
    bit_size_from: byte_aligned_bit_size_generator(0),
  )
}

/// Generate non-empty byte-aligned bit arrays.
///
pub fn non_empty_byte_aligned_bit_array() -> Generator(BitArray) {
  generic_bit_array(
    values_from: unsigned_byte(),
    bit_size_from: byte_aligned_bit_size_generator(1),
  )
}

/// Generate byte-aligned bit arrays of the given number of bytes
///
/// ### Arguments
///
/// - `num_bytes`: Number of bytes for the generated bit array
///
/// ### Returns
///
/// A generator that produces bit arrays with the specified number of bytes
///
/// ### Example
///
/// Generate 4-byte bit arrays:
///
/// ```
/// fixed_size_byte_aligned_bit_array(4)
/// ```
///
pub fn fixed_size_byte_aligned_bit_array(num_bytes: Int) -> Generator(BitArray) {
  let num_bits = ensure_positive_or_zero(num_bytes) * 8
  fixed_size_bit_array(num_bits)
}

/// Generate byte-aligned bit arrays of the given number of bytes from the
/// given value generator
///
/// ### Arguments
///
/// - `value_generator`: Generates the values of the bit array
/// - `num_bytes`: Number of bytes for the generated bit array
///
/// ### Returns
///
/// A generator that produces bit arrays with the specified number of bytes
/// according to the given value generator
///
/// ### Example
///
/// Generate 4-byte bit arrays:
///
/// ```
/// fixed_size_byte_aligned_bit_array(bounded_int(0, 255), 16)
/// ```
///
pub fn fixed_size_byte_aligned_bit_array_from(
  value_generator: Generator(Int),
  byte_size: Int,
) -> Generator(BitArray) {
  let bit_size = byte_size * 8
  fixed_size_bit_array_from(value_generator, bit_size)
}

/// Generate byte-aligned bit arrays according to the given value generator
/// and byte size generator.
///
/// ### Arguments
///
/// - `value_generator`: Generates the values of the bit array
/// - `byte_size_generator`: Generates the number of bytes of the bit array
///
/// ### Returns
///
/// A byte-aligned bit array generator
///
pub fn generic_byte_aligned_bit_array(
  values_from value_generator: Generator(Int),
  byte_size_from byte_size_generator: Generator(Int),
) -> Generator(BitArray) {
  use byte_size <- bind(byte_size_generator)
  fixed_size_byte_aligned_bit_array_from(value_generator, byte_size)
}

/// Generate a number from the sequence `[0, 8, 16, ..., 128]`.
///
fn byte_aligned_bit_size_generator(min: Int) -> Generator(Int) {
  use num_bytes <- map(bounded_int(min, 16))
  let num_bits = 8 * num_bytes
  num_bits
}

// MARK: TestError

type TestError(a) {
  TestError(
    original_value: a,
    shrunk_value: a,
    shrink_steps: Int,
    error_msg: String,
  )
}

fn new_test_error(
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

// MARK: Try

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

// MARK: Utils

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
/// Convert an int to a codepoint.
///
/// If the given int does not
/// represent a valid codepoint, returns try to convert `default` into a valid
/// codepoint.
///
/// If that too doesn't work, then just return `"a"` -- but you should ensure
/// that `default` will be a valid codepoint or you may mess up the expected
/// shrinking behavior.
///
fn int_to_codepoint(n: Int, on_error default: Int) -> UtfCodepoint {
  case string.utf_codepoint(n) {
    Ok(cp) -> cp
    Error(Nil) -> {
      case string.utf_codepoint(default) {
        Ok(cp) -> cp
        Error(Nil) -> {
          // This assert is safe as long as ascii_a_lowercase constant is
          // defined correctly.
          let assert Ok(cp) = string.utf_codepoint(ascii_a_lowercase)
          cp
        }
      }
    }
  }
}

/// Return the first codepoint of a given string, or if the string is empty return the codepoint for `a`.
/// Return the codepoint representation of the character.
///
/// If the given character is a multicodepoint grapheme cluster, only returns
/// the first codepoint in the cluster.
///
/// If `n <= 0` return `0`, else return `n`.
fn ensure_positive_or_zero(n: Int) -> Int {
  case int.compare(n, 0) {
    order.Gt | order.Eq -> n
    order.Lt -> 0
  }
}
