import gleam/dict.{type Dict}
import gleam/float
import gleam/function
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{type Option, None}
import gleam/set
import gleam/string
import gleam/string_builder
import prng/random
import prng/seed.{type Seed}
import qcheck/shrink
import qcheck/tree.{type Tree, Tree}
import qcheck/utils

pub type Generator(a) {
  Generator(fn(Seed) -> #(Tree(a), Seed))
}

pub fn generate_tree(gen: Generator(a), seed: Seed) -> #(Tree(a), Seed) {
  let Generator(generate) = gen

  generate(seed)
}

fn make_primative(
  random_generator random_generator: random.Generator(a),
  make_tree make_tree: fn(a) -> Tree(a),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(generated_value, next_seed) = random.step(random_generator, seed)

    #(make_tree(generated_value), next_seed)
  })
}

// basics
//
//

pub fn return(a) {
  Generator(fn(seed) { #(tree.return(a), seed) })
}

// These arguments also feel reversed (see apply).
pub fn map(generator: Generator(a), f: fn(a) -> b) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree = tree.map(tree, f)

    #(tree, seed)
  })
}

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

pub fn map2(f: fn(a, b) -> c, a: Generator(a), b: Generator(b)) -> Generator(c) {
  f
  |> function.curry2
  |> return
  |> apply(a)
  |> apply(b)
}

pub fn map3(
  f: fn(a, b, c) -> d,
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
) -> Generator(d) {
  f
  |> function.curry3
  |> return
  |> apply(a)
  |> apply(b)
  |> apply(c)
}

pub fn map4(
  f: fn(a, b, c, d) -> e,
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
  d: Generator(d),
) -> Generator(e) {
  f
  |> function.curry4
  |> return
  |> apply(a)
  |> apply(b)
  |> apply(c)
  |> apply(d)
}

pub fn map5(
  f: fn(a, b, c, d, e) -> f,
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
  d: Generator(d),
  e: Generator(e),
) -> Generator(f) {
  f
  |> function.curry5
  |> return
  |> apply(a)
  |> apply(b)
  |> apply(c)
  |> apply(d)
  |> apply(e)
}

pub fn map6(
  f: fn(a, b, c, d, e, f) -> g,
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
  d: Generator(d),
  e: Generator(e),
  f_: Generator(f),
) -> Generator(g) {
  f
  |> function.curry6
  |> return
  |> apply(a)
  |> apply(b)
  |> apply(c)
  |> apply(d)
  |> apply(e)
  |> apply(f_)
}

pub fn tuple2(a: Generator(a), b: Generator(b)) -> Generator(#(a, b)) {
  fn(a, b) { #(a, b) }
  |> map2(a, b)
}

pub fn tuple3(
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
) -> Generator(#(a, b, c)) {
  fn(a, b, c) { #(a, b, c) }
  |> map3(a, b, c)
}

pub fn tuple4(
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
  d: Generator(d),
) -> Generator(#(a, b, c, d)) {
  fn(a, b, c, d) { #(a, b, c, d) }
  |> map4(a, b, c, d)
}

pub fn tuple5(
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
  d: Generator(d),
  e: Generator(e),
) -> Generator(#(a, b, c, d, e)) {
  fn(a, b, c, d, e) { #(a, b, c, d, e) }
  |> map5(a, b, c, d, e)
}

pub fn tuple6(
  a: Generator(a),
  b: Generator(b),
  c: Generator(c),
  d: Generator(d),
  e: Generator(e),
  f: Generator(f),
) -> Generator(#(a, b, c, d, e, f)) {
  fn(a, b, c, d, e, f) { #(a, b, c, d, e, f) }
  |> map6(a, b, c, d, e, f)
}

/// Chooses a generator from a list of generators weighted uniformly, then
/// chooses a value from that generator.
pub fn from_generators(generators) {
  // TODO: better error message on empty list
  let assert [generator, ..generators] = generators

  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      random.uniform(generator, generators)
      |> random.step(seed)

    generator(seed)
  })
}

/// Chooses a generator from a list of generators weighted by the given weights,
/// then chooses a value from that generator.
/// 
/// TODO: describe requirements for weights
pub fn from_weighted_generators(generators) {
  // TODO: better error message on empty list
  let assert [generator, ..generators] = generators

  Generator(fn(seed) {
    let #(Generator(generator), seed) =
      random.weighted(generator, generators)
      |> random.step(seed)

    generator(seed)
  })
}

// ints
//
//

// TODO: consider switching to base_quickcheck small int generator
/// This is good for generating sizes of things like lists or strings.
pub fn small_positive_or_zero_int() -> Generator(Int) {
  make_primative(
    random_generator: random.float(0.0, 1.0)
      |> random.then(fn(x) {
      case x <. 0.75 {
        True -> random.int(0, 10)
        False -> random.int(0, 100)
      }
    }),
    make_tree: fn(n) {
      tree.make_primative(root: n, shrink: shrink.int_towards_zero())
    },
  )
}

pub fn small_strictly_positive_int() -> Generator(Int) {
  small_positive_or_zero_int()
  |> map(int.add(_, 1))
}

// The QCheck2 code does some fancy stuff to avoid generating ranges wider than
// `Int.max_int`. TODO: consider the implications for this code.
//
// TODO: QCheck2 code also has a parameter for the shrink origin.
pub fn int_uniform_inclusive(low: Int, high: Int) -> Generator(Int) {
  case high < low {
    True -> panic as "int_uniform_includive: high < low"
    False -> Nil
  }

  make_primative(random_generator: random.int(low, high), make_tree: fn(n) {
    let origin = utils.pick_origin_within_range(low, high, goal: 0)

    tree.make_primative(root: n, shrink: shrink.int_towards(origin))
  })
}

// WARNING: doesn't hit the interesting cases very often.  Use something more like
//   qcheck2 or base_quickcheck.
pub fn int_uniform() -> Generator(Int) {
  int_uniform_inclusive(random.min_int, random.max_int)
}

type GenerateOption {
  GenerateNone
  GenerateSome
}

fn generate_option() -> random.Generator(GenerateOption) {
  random.weighted(#(0.15, GenerateNone), [#(0.85, GenerateSome)])
}

/// `option(generator)` shrinks towards `None` then towards shrinks of
/// `generator`. 
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

// char
//
//

// Though gleam doesn't have a `Char` type, we need these one-character string
// generators so that we can shrink the `Generator(String)` type properly.

const char_min_value: Int = 0

// TODO: what is a reasonable value here?
const char_max_value: Int = 255

// TODO: why not take the "char" directly?
// For now, this is only used in setting up the string generators.
pub fn char_uniform_inclusive(low: Int, high: Int) -> Generator(String) {
  let a = 97
  let origin = utils.pick_origin_within_range(low, high, goal: a)
  let shrink = shrink.int_towards(origin)

  Generator(fn(seed) {
    let #(n, seed) =
      random.int(low, high)
      |> random.step(seed)

    let tree =
      tree.make_primative(n, shrink)
      |> tree.map(utils.int_to_char)

    #(tree, seed)
  })
}

pub fn char_uppercase() -> Generator(String) {
  let a = utils.char_to_int("A")
  let z = utils.char_to_int("Z")

  char_uniform_inclusive(a, z)
}

pub fn char_lowercase() -> Generator(String) {
  let a = utils.char_to_int("a")
  let z = utils.char_to_int("z")

  char_uniform_inclusive(a, z)
}

pub fn char_digit() -> Generator(String) {
  let zero = utils.char_to_int("0")
  let nine = utils.char_to_int("9")

  char_uniform_inclusive(zero, nine)
}

// TODO: name char_printable_uniform?
// Note: the shrink target for this will be `"a"`.
pub fn char_print_uniform() -> Generator(String) {
  let space = utils.char_to_int(" ")
  let tilde = utils.char_to_int("~")

  char_uniform_inclusive(space, tilde)
}

pub fn char_uniform() -> Generator(String) {
  char_uniform_inclusive(char_min_value, char_max_value)
}

pub fn char_alpha() -> Generator(String) {
  [char_uppercase(), char_lowercase()]
  |> from_generators
}

pub fn char_alpha_numeric() -> Generator(String) {
  [#(52.0, char_alpha()), #(10.0, char_digit())]
  |> from_weighted_generators
}

pub fn char_from_list(chars: List(String)) -> Generator(String) {
  let ints = list.map(chars, utils.char_to_int)
  // TODO: assert that they are all single length chars
  let assert [hd, ..tl] = ints

  // Take the char with the minimum int representation as the shrink target.
  let shrink_target = list.fold(tl, hd, int.min)

  Generator(fn(seed) {
    let #(n, seed) =
      random.uniform(hd, tl)
      |> random.step(seed)

    let tree =
      tree.make_primative(n, shrink.int_towards(shrink_target))
      |> tree.map(utils.int_to_char)

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

pub fn char_whitespace() -> Generator(String) {
  all_char_list()
  |> list.filter(char_is_whitespace)
  |> list.map(utils.int_to_char)
  |> char_from_list
}

pub fn char_print() -> Generator(String) {
  from_weighted_generators([
    #(10.0, char_alpha_numeric()),
    #(1.0, char_print_uniform()),
  ])
}

pub fn char() {
  from_weighted_generators([
    #(100.0, char_print()),
    #(10.0, char_uniform()),
    #(1.0, return(utils.int_to_char(char_min_value))),
    #(1.0, return(utils.int_to_char(char_max_value))),
  ])
}

// string
//
//

fn do_gen_string(i, string_builder, char_gen, char_trees_rev, seed) {
  let Generator(gen_char_tree) = char_gen

  let #(char_tree, seed) = gen_char_tree(seed)

  case i <= 0 {
    True -> #(string_builder.to_string(string_builder), char_trees_rev, seed)
    False -> {
      let Tree(root, _) = char_tree

      do_gen_string(
        i - 1,
        string_builder
          |> string_builder.append(root),
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
/// Generate strings of the given length from the given character generator.
pub fn string_with_length_from(
  char_gen: Generator(String),
  size,
) -> Generator(String) {
  Generator(fn(seed) {
    let #(generated_string, char_trees_rev, seed) =
      do_gen_string(size, string_builder.new(), char_gen, [], seed)

    // TODO: Ideally this whole thing would be delayed until needed.
    let shrink = fn() {
      let char_trees: List(Tree(String)) = list.reverse(char_trees_rev)
      let char_list_tree: Tree(List(String)) = tree.iterator_list(char_trees)

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

/// Fully customizable string generator.
pub fn string_generic(char_gen, length_gen) {
  length_gen
  |> bind(string_with_length_from(char_gen, _))
}

/// Generate strings with the default character generator and the default length
/// generator.
pub fn string() -> Generator(String) {
  bind(small_positive_or_zero_int(), fn(length) {
    string_with_length_from(char(), length)
  })
}

/// Generate non-empty strings with the default character generator and the
/// default length generator.
pub fn string_non_empty() -> Generator(String) {
  bind(small_strictly_positive_int(), fn(length) {
    string_with_length_from(char(), length)
  })
}

/// Generate strings of the given length with the default character generator.
pub fn string_with_length(length: Int) -> Generator(String) {
  string_with_length_from(char(), length)
}

/// Generate strings from the given character generator using the default length
/// generator.
pub fn string_from(char_gen: Generator(String)) -> Generator(String) {
  bind(small_positive_or_zero_int(), fn(length) {
    string_with_length_from(char_gen, length)
  })
}

/// Generate non-empty strings from the given character generator using the
/// default length generator.
pub fn string_non_empty_from(char_gen: Generator(String)) -> Generator(String) {
  bind(small_strictly_positive_int(), fn(length) {
    string_with_length_from(char_gen, length)
  })
}

// Nil (unit type)
//
//

pub fn nil() -> Generator(Nil) {
  Generator(fn(seed) { #(tree.return(Nil), seed) })
}

// Bool
//
//

pub fn bool() -> Generator(Bool) {
  Generator(fn(seed) {
    let #(bool, seed) =
      random.choose(True, False)
      |> random.step(seed)

    let tree = case bool {
      True -> Tree(True, iterator.once(fn() { tree.return(False) }))
      False -> tree.return(False)
    }

    #(tree, seed)
  })
}

// Float
//
// 

fn exp(x: Float) -> Float {
  let assert Ok(result) = float.power(2.71828, x)
  result
}

// Note: The base_quickcheck float generators are much fancier.  Should consider
// using their generation method.
pub fn float() -> Generator(Float) {
  Generator(fn(seed) {
    let #(x, seed) =
      random.float(0.0, 15.0)
      |> random.step(seed)

    let #(y, seed) =
      random.choose(1.0, -1.0)
      |> random.step(seed)
    let #(z, seed) =
      random.choose(1.0, -1.0)
      |> random.step(seed)

    // The QCheck2.Gen.float code has this double multiply in it. Actually not
    // sure about that.
    let generated_value = exp(x) *. y *. z

    let tree = tree.make_primative(generated_value, shrink.float_towards_zero())

    #(tree, seed)
  })
}

// List
//
// 

fn list_generic_loop(
  n: Int,
  acc: Tree(List(a)),
  elt_gen: Generator(a),
  seed: Seed,
) -> #(Tree(List(a)), Seed) {
  case n <= 0 {
    True -> #(acc, seed)
    False -> {
      let Generator(generate) = elt_gen
      let #(tree, seed) = generate(seed)

      list_generic_loop(
        n - 1,
        tree.map2(utils.list_cons, tree, acc),
        elt_gen,
        seed,
      )
    }
  }
}

pub fn list_generic(
  elt_gen: Generator(a),
  min_length min_len: Int,
  max_length max_len: Int,
) -> Generator(List(a)) {
  int_uniform_inclusive(min_len, max_len)
  |> bind(fn(length) {
    Generator(fn(seed) {
      list_generic_loop(length, tree.return([]), elt_gen, seed)
    })
  })
}

// Set
//
// 

pub fn set_generic(elt_gen: Generator(a), max_length max_len: Int) {
  list_generic(elt_gen, 0, max_len)
  |> map(set.from_list)
}

// Dict
//
// 

pub fn dict_generic(
  key key: Generator(key),
  value value: Generator(value),
  max_length max_length: Int,
) -> Generator(Dict(key, value)) {
  tuple2(key, value)
  |> list_generic(1, max_length)
  |> map(dict.from_list)
}
