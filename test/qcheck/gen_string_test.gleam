import birdie
import gleam/function
import gleam/iterator
import gleam/list
import gleam/regexp
import gleam/string
import gleeunit/should
import qcheck.{type Tree, Tree}

const test_count: Int = 5000

pub fn string_generic__test() {
  let assert Ok(all_letters) =
    regexp.compile(
      "^[a-z]+$",
      regexp.Options(case_insensitive: False, multi_line: False),
    )

  let has_only_a_through_z = fn(s) { regexp.check(all_letters, s) }

  qcheck.run(
    config: qcheck.default_config(),
    // a - z
    generator: qcheck.string_generic(
      qcheck.char_uniform_inclusive(97, 122),
      qcheck.int_uniform_inclusive(1, 10),
    ),
    property: fn(s) {
      // io.debug(s)
      let s_len = string.length(s)

      1 <= s_len && s_len <= 10 && has_only_a_through_z(s)
    },
  )
}

pub fn string_generic__failure_doesnt_mess_up_shrinks__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.string_generic(
        qcheck.char_uniform_inclusive(97, 122),
        // The empty string should not be generated because it is outside of the
        // possible generated lengths.
        qcheck.int_uniform_inclusive(3, 6),
      ),
      property: fn(s) {
        string.contains(s, "a")
        || string.contains(s, "b")
        || string.length(s) >= 4
      },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect("ccc"))
}

pub fn string_generic__shrinks_okay_2__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.string_generic(
        qcheck.char_uniform_inclusive(97, 122),
        qcheck.int_uniform_inclusive(1, 10),
      ),
      property: fn(s) {
        let len = string.length(s)
        len <= 5 || len >= 10 || string.contains(s, "a")
      },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect("bbbbbb"))
}

pub fn string_with_length_from__shrinks_okay__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.char_uniform_inclusive(97, 122)
        |> qcheck.string_with_length_from(2),
      property: fn(s) { !string.contains(s, "x") },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["ax", "xa"])
}

pub fn string_generic__shrinks_okay__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.string_generic(
        qcheck.char_uniform_inclusive(97, 122),
        qcheck.int_uniform_inclusive(1, 10),
      ),
      property: fn(s) {
        let len = string.length(s)
        len <= 5 || len >= 10
      },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect("aaaaaa"))
}

pub fn string_generators_shrink_on_size_then_on_characters__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.string_generic(
        // Shrinks to `a`
        qcheck.char_uniform_inclusive(97, 99),
        qcheck.int_uniform_inclusive(2, 5),
      ),
      qcheck.seed_new(3),
    )

  tree
  |> qcheck.tree_to_string(function.identity)
  |> birdie.snap("string_generators_shrink_on_size_then_on_characters__test")
}

fn check_tree_nodes(tree: Tree(a), predicate: fn(a) -> Bool) -> Bool {
  let Tree(root, children) = tree

  let all_true = fn(it) {
    it
    |> iterator.all(function.identity)
  }

  case predicate(root) {
    True ->
      iterator.map(children, fn(tree: Tree(a)) {
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
    qcheck.generate_tree(
      qcheck.string_with_length_from(
        // Shrinks to `a`
        qcheck.char_uniform_inclusive(97, 99),
        length,
      ),
      // Use a random seed here so it tests a new tree each run.
      qcheck.seed_random(),
    )

  tree
  |> check_tree_nodes(string_length_is(length))
  |> should.be_true
}

// The string shrinking is basically tested above and not tested here in the
// context of the `qcheck.run`.

pub fn string_smoke_test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.string(),
    property: fn(s) { string.length(s) >= 0 },
  )
}

pub fn string_non_empty_generates_non_empty_strings__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.string_non_empty(),
    property: fn(s) { string.length(s) > 0 },
  )
}

pub fn string_with_length__generates_length_n_strings__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.string_with_length(3),
    property: string_length_is(3),
  )
}

pub fn string_from__generates_correct_values__test() {
  let assert Ok(all_ascii_lowercase) =
    regexp.compile(
      "^[a-z]+$",
      regexp.Options(case_insensitive: False, multi_line: False),
    )

  qcheck.run(
    config: qcheck.default_config()
      |> qcheck.with_test_count(test_count),
    generator: qcheck.string_from(qcheck.char_lowercase()),
    property: fn(s) {
      string.is_empty(s) || regexp.check(all_ascii_lowercase, s)
    },
  )
}

pub fn string_non_empty_from__generates_correct_values__test() {
  let assert Ok(all_ascii_lowercase) =
    regexp.compile(
      "^[a-z]+$",
      regexp.Options(case_insensitive: False, multi_line: False),
    )

  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.string_non_empty_from(qcheck.char_lowercase()),
    property: fn(s) { regexp.check(all_ascii_lowercase, s) },
  )
}

// utils
//
//

fn should_be_one_of(x, strings) {
  let assert Ok(_) =
    strings
    |> list.map(string.inspect)
    |> list.find(one_that: fn(el) { el == x })

  Nil
}
