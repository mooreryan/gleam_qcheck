import birdie
import gleam/function
import gleam/iterator
import gleam/regex
import gleam/string
import gleeunit/should
import prng/seed
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/tree

pub fn string_generic__test() {
  let assert Ok(all_letters) =
    regex.compile(
      "^[a-z]+$",
      regex.Options(case_insensitive: False, multi_line: False),
    )

  let has_only_a_through_z = fn(s) { regex.check(all_letters, s) }

  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_generic(
      generator.char_uniform_inclusive(97, 122),
      generator.int_uniform_inclusive(1, 10),
    ),
    property: fn(s) {
      // io.debug(s)
      let s_len = string.length(s)

      1 <= s_len && s_len <= 10 && has_only_a_through_z(s)
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn string_generic__failure_doesnt_mess_up_shrinks__test() {
  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_generic(
      generator.char_uniform_inclusive(97, 122),
      // The empty string should not be generated because it is outside of the
      // possible generated lengths.
      generator.int_uniform_inclusive(3, 6),
    ),
    property: fn(s) {
      string.contains(s, "a")
      || string.contains(s, "b")
      || string.length(s) >= 4
    },
  )
  |> should.equal(Error("ccc"))
}

pub fn string_generic__shrinks_okay_2__test() {
  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_generic(
      generator.char_uniform_inclusive(97, 122),
      generator.int_uniform_inclusive(1, 10),
    ),
    property: fn(s) {
      let len = string.length(s)
      len <= 5 || len >= 10 || string.contains(s, "a")
    },
  )
  |> should.equal(Error("bbbbbb"))
}

pub fn string_with_length_from__shrinks_okay__test() {
  let run_result =
    qtest.run(
      config: qtest_config.default(),
      // a - z
      generator: generator.char_uniform_inclusive(97, 122)
        |> generator.string_with_length_from(2),
      property: fn(s) { !string.contains(s, "x") },
    )

  let result = case run_result {
    Error("ax") -> True
    Error("xa") -> True
    _ -> False
  }

  should.be_true(result)
}

pub fn string_generic__shrinks_okay__test() {
  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_generic(
      generator.char_uniform_inclusive(97, 122),
      generator.int_uniform_inclusive(1, 10),
    ),
    property: fn(s) {
      let len = string.length(s)
      len <= 5 || len >= 10
    },
  )
  |> should.equal(Error("aaaaaa"))
}

pub fn string_generators_shrink_on_size_then_on_characters__test() {
  let #(tree, _seed) =
    generator.generate_tree(
      generator.string_generic(
        // Shrinks to `a`
        generator.char_uniform_inclusive(97, 99),
        generator.int_uniform_inclusive(2, 5),
      ),
      seed.new(3),
    )

  tree
  |> tree.to_string(function.identity)
  |> birdie.snap("string_generators_shrink_on_size_then_on_characters__test")
}

fn check_tree_nodes(tree: tree.Tree(a), predicate: fn(a) -> Bool) -> Bool {
  let tree.Tree(root, children) = tree

  let all_true = fn(it) {
    it
    |> iterator.all(function.identity)
  }

  case predicate(root) {
    True ->
      iterator.map(children, fn(tree: tree.Tree(a)) {
        check_tree_nodes(tree, predicate)
      })
      |> all_true
    False -> False
  }
}

fn string_length_is(length) {
  fn(s) { string.length(s) == length }
}

pub fn string_generators_with_specific_length_dont_shrink_on_length__test() {
  // Keep this low to keep the speed of the test high.
  let length = 3

  let #(tree, _seed) =
    generator.generate_tree(
      generator.string_with_length_from(
        // Shrinks to `a`
        generator.char_uniform_inclusive(97, 99),
        length,
      ),
      // Use a random seed here so it tests a new tree each run.
      seed.random(),
    )

  tree
  |> check_tree_nodes(string_length_is(length))
  |> should.be_true
}

// The string shrinking is basically tested above and not tested here in the
// context of the `qtest.run`.

// TODO: these string generators are quite slow!

pub fn string_smoke_test() {
  qtest.run(
    config: qtest_config.default()
      // TODO: this single test is about 1.5s using the default config.
      |> qtest_config.with_test_count(100),
    generator: generator.string(),
    property: fn(s) { string.length(s) >= 0 },
  )
  |> should.equal(Ok(Nil))
}

pub fn string_non_empty_generates_non_empty_strings__test() {
  qtest.run(
    config: qtest_config.default()
      // TODO: this single test is about 1.5s using the default config.
      |> qtest_config.with_test_count(100),
    generator: generator.string_non_empty(),
    property: fn(s) { string.length(s) > 0 },
  )
  |> should.equal(Ok(Nil))
}

pub fn string_with_length__generates_length_n_strings__test() {
  qtest.run(
    config: qtest_config.default()
      // TODO: this single test is about 1.5s using the default config.
      |> qtest_config.with_test_count(100),
    generator: generator.string_with_length(3),
    property: string_length_is(3),
  )
  |> should.equal(Ok(Nil))
}

pub fn string_from__generates_correct_values__test() {
  let assert Ok(all_ascii_lowercase) =
    regex.compile(
      "^[a-z]+$",
      regex.Options(case_insensitive: False, multi_line: False),
    )

  qtest.run(
    config: qtest_config.default()
      |> qtest_config.with_test_count(100),
    generator: generator.string_from(generator.char_lowercase()),
    property: fn(s) {
      string.is_empty(s) || regex.check(all_ascii_lowercase, s)
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn string_non_empty_from__generates_correct_values__test() {
  let assert Ok(all_ascii_lowercase) =
    regex.compile(
      "^[a-z]+$",
      regex.Options(case_insensitive: False, multi_line: False),
    )

  qtest.run(
    config: qtest_config.default()
      |> qtest_config.with_test_count(100),
    generator: generator.string_non_empty_from(generator.char_lowercase()),
    property: fn(s) { regex.check(all_ascii_lowercase, s) },
  )
  |> should.equal(Ok(Nil))
}
