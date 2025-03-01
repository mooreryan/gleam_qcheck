import birdie
import gleam/function
import gleam/list
import gleam/regexp
import gleam/string
import gleam/yielder
import gleeunit/should
import qcheck
import qcheck/test_error_message
import qcheck/tree.{type Tree, Tree}

const test_count: Int = 5000

pub fn generic_string__test() {
  let assert Ok(all_letters) =
    regexp.compile(
      "^[a-z]+$",
      regexp.Options(case_insensitive: False, multi_line: False),
    )

  let has_only_a_through_z = fn(s) { regexp.check(all_letters, s) }

  use s <- qcheck.run(
    config: qcheck.default_config(),
    // a - z
    generator: qcheck.generic_string(
      qcheck.bounded_codepoint(97, 122),
      qcheck.bounded_int(1, 10),
    ),
  )
  let s_len = string.length(s)
  should.be_true(1 <= s_len && s_len <= 10 && has_only_a_through_z(s))
}

pub fn generic_string__failure_does_not_mess_up_shrinks__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use s <- qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.generic_string(
        qcheck.bounded_codepoint(97, 122),
        // The empty string should not be generated because it is outside of the
        // possible generated lengths.
        qcheck.bounded_int(3, 6),
      ),
    )
    should.be_true(
      string.contains(s, "a")
      || string.contains(s, "b")
      || string.length(s) >= 4,
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect("ccc"))
}

pub fn generic_string__shrinks_okay_2__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use s <- qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.generic_string(
        qcheck.bounded_codepoint(97, 122),
        qcheck.bounded_int(1, 10),
      ),
    )
    let len = string.length(s)
    should.be_true(len <= 5 || len >= 10 || string.contains(s, "a"))
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect("bbbbbb"))
}

pub fn fixed_length_string_from__shrinks_okay__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use s <- qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.bounded_codepoint(97, 122)
        |> qcheck.fixed_length_string_from(2),
    )
    should.be_false(string.contains(s, "x"))
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["ax", "xa"])
}

pub fn generic_string__shrinks_okay__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use s <- qcheck.run(
      config: qcheck.default_config(),
      // a - z
      generator: qcheck.generic_string(
        qcheck.bounded_codepoint(97, 122),
        qcheck.bounded_int(1, 10),
      ),
    )
    let len = string.length(s)
    should.be_true(len <= 5 || len >= 10)
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(string.inspect("aaaaaa"))
}

pub fn string_generators_shrink_on_size_then_on_characters__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.generic_string(
        // Shrinks to `a`
        qcheck.bounded_codepoint(97, 99),
        qcheck.bounded_int(2, 5),
      ),
      qcheck.seed(3),
    )

  tree
  |> tree.to_string(function.identity)
  |> birdie.snap("string_generators_shrink_on_size_then_on_characters__test")
}

fn check_tree_nodes(tree: Tree(a), predicate: fn(a) -> Bool) -> Bool {
  let Tree(root, children) = tree

  let all_true = fn(it) {
    it
    |> yielder.all(function.identity)
  }

  case predicate(root) {
    True ->
      yielder.map(children, fn(tree: Tree(a)) {
        check_tree_nodes(tree, predicate)
      })
      |> all_true
    False -> False
  }
}

// TODO: once string generators generate strings whose length always matches
// `string.length`, change this back to being an exact equality.
fn string_length_is_at_most(length) {
  fn(s) { should.be_true(string.length(s) <= length) }
}

pub fn string_generators_with_specific_length_dont_shrink_on_length__test() {
  // Keep this low to keep the speed of the test high.
  let length = 3

  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.fixed_length_string_from(
        // Shrinks to `a`
        qcheck.bounded_codepoint(97, 99),
        length,
      ),
      // Use a random seed here so it tests a new tree each run.
      qcheck.random_seed(),
    )

  let string_length_is_at_most = fn(length) {
    fn(s) { string.length(s) <= length }
  }

  tree
  // We use at most here because string.length will "merge" some values it
  // considers a single grapheme, but we generate strings that have the given
  // number of codepoints.
  |> check_tree_nodes(string_length_is_at_most(length))
  |> should.be_true
}

// The string shrinking is basically tested above and not tested here in the
// context of the `qcheck.run`.

pub fn string_smoke_test() {
  use s <- qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.string(),
  )
  should.be_true(string.length(s) >= 0)
}

pub fn non_empty_string_generates_non_empty_strings__test() {
  use s <- qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.non_empty_string(),
  )
  should.be_true(string.length(s) > 0)
}

pub fn fixed_length_string__generates_length_n_strings__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.fixed_length_string_from(qcheck.codepoint(), 3),
    // We use at most here because string.length will "merge" some values it
    // considers a single grapheme (e.g., `\r\n`), but we generate strings that
    // have the given number of codepoints.
    property: string_length_is_at_most(3),
  )
}

pub fn fixed_length_string__generates_length_n_strings_2__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.fixed_length_string_from(
      // This generator will never generate codepoints that can combine to form
      // a multicodepoint string.
      qcheck.lowercase_ascii_codepoint(),
      3,
    ),
    // We use at most here because string.length will "merge" some values it
    // considers a single grapheme (e.g., `\r\n`), but we generate strings that
    // have the given number of codepoints.
    property: fn(s) { should.equal(string.length(s), 3) },
  )
}

pub fn string_from__generates_correct_values__test() {
  let assert Ok(all_ascii_lowercase) =
    regexp.compile(
      "^[a-z]+$",
      regexp.Options(case_insensitive: False, multi_line: False),
    )

  use s <- qcheck.run(
    config: qcheck.default_config()
      |> qcheck.with_test_count(test_count),
    generator: qcheck.string_from(qcheck.lowercase_ascii_codepoint()),
  )
  should.be_true(string.is_empty(s) || regexp.check(all_ascii_lowercase, s))
}

pub fn non_empty_string_from__generates_correct_values__test() {
  let assert Ok(all_ascii_lowercase) =
    regexp.compile(
      "^[a-z]+$",
      regexp.Options(case_insensitive: False, multi_line: False),
    )

  use s <- qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: qcheck.non_empty_string_from(qcheck.lowercase_ascii_codepoint()),
  )
  should.be_true(regexp.check(all_ascii_lowercase, s))
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
