import gleam/int
import gleam/list
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn bounded_codepoint__test() {
  use codepoint <- qcheck.run(
    qcheck.default_config(),
    qcheck.bounded_codepoint(500, 1000),
  )
  let n = string.utf_codepoint_to_int(codepoint)
  should.be_true(500 <= n && n <= 1000)
}

pub fn bounded_codepoint__ranges_that_include_invalid_codepoints_are_okay__test() {
  use codepoint <- qcheck.run(
    qcheck.default_config() |> qcheck.with_test_count(10_000),
    qcheck.bounded_codepoint(55_200, 58_000),
  )
  let n = string.utf_codepoint_to_int(codepoint)
  should.be_true(55_200 <= n && n <= 58_000)
}

pub fn bounded_codepoint__ranges_that_include_only_invalid_codepoints_are_corrected__test() {
  use codepoint <- qcheck.run(
    qcheck.default_config() |> qcheck.with_test_count(10_000),
    qcheck.bounded_codepoint(55_296, 57_343),
  )
  let n = string.utf_codepoint_to_int(codepoint)
  should.equal(n, 97)
}

pub fn bounded_codepoint__low_greater_than_hi__test() {
  use codepoint <- qcheck.run(
    qcheck.default_config() |> qcheck.with_test_count(10_000),
    qcheck.bounded_codepoint(70, 65),
  )
  let n = string.utf_codepoint_to_int(codepoint)
  should.be_true(65 <= n && n <= 70)
}

pub fn bounded_codepoint__codepoints_out_of_range__test() {
  qcheck.run(
    qcheck.default_config() |> qcheck.with_test_count(10_000),
    qcheck.bounded_codepoint(-2_000_000, 2_000_000),
    it_doesnt_crash,
  )
}

fn it_doesnt_crash(_) {
  should.be_true(True)
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bounded_codepoint__failures_shink_ok__test() -> Nil {
  let expected = string.inspect(500)

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use codepoint <- qcheck.run(
      qcheck.default_config(),
      qcheck.bounded_codepoint(500, 1000),
    )
    let n = string.utf_codepoint_to_int(codepoint)
    should.be_true(600 <= n && n <= 900)
  }

  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

fn has_one_codepoint_in_range(
  codepoint: UtfCodepoint,
  low: Int,
  high: Int,
) -> Bool {
  let n = string.utf_codepoint_to_int(codepoint)

  low <= n && n <= high
}

fn assert_has_one_codepoint_in_range(
  codepoint: UtfCodepoint,
  low: Int,
  high: Int,
) -> Nil {
  let n = string.utf_codepoint_to_int(codepoint)

  should.be_true(low <= n && n <= high)
}

pub fn uppercase_character__test() {
  qcheck.run(
    qcheck.default_config(),
    qcheck.uppercase_ascii_codepoint(),
    assert_has_one_codepoint_in_range(_, int("A"), int("Z")),
  )
}

pub fn uppercase_character__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = inspect_first_codepoint("Z")

  let assert Error(msg) = {
    use <- test_error_message.rescue

    qcheck.run(
      qcheck.default_config(),
      qcheck.uppercase_ascii_codepoint(),
      assert_has_one_codepoint_in_range(_, int("A") + 2, int("Z") - 2),
    )
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

pub fn lowercase_character__test() {
  qcheck.run(
    qcheck.default_config(),
    qcheck.lowercase_ascii_codepoint(),
    assert_has_one_codepoint_in_range(_, int("a"), int("z")),
  )
}

pub fn lowercase_character__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = inspect_first_codepoint("a")

  let assert Error(msg) = {
    use <- test_error_message.rescue

    qcheck.run(
      qcheck.default_config(),
      qcheck.lowercase_ascii_codepoint(),
      assert_has_one_codepoint_in_range(_, int("a") + 2, int("z") - 2),
    )
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

pub fn digit_character__test() {
  qcheck.run(
    qcheck.default_config(),
    qcheck.ascii_digit_codepoint(),
    assert_has_one_codepoint_in_range(_, int("0"), int("9")),
  )
}

pub fn digit_character__failures_shink_ok__test() {
  // "9" is less than "a" => "9" is "closer" to "a" so that is the shrink
  // target.
  let expected = inspect_first_codepoint("9")

  let assert Error(msg) = {
    use <- test_error_message.rescue

    qcheck.run(
      qcheck.default_config(),
      qcheck.ascii_digit_codepoint(),
      assert_has_one_codepoint_in_range(_, int("0") + 2, int("9") - 2),
    )
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

pub fn uniform_printable_character__test() {
  qcheck.run(
    qcheck.default_config(),
    qcheck.uniform_printable_ascii_codepoint(),
    assert_has_one_codepoint_in_range(_, int(" "), int("~")),
  )
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn uniform_printable_character__failures_shink_ok__test() -> Nil {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      qcheck.default_config(),
      qcheck.uniform_printable_ascii_codepoint(),
      // TODO: These tests with `int` need to be fixed
      assert_has_one_codepoint_in_range(_, int(" ") + 2, int("~") - 2),
    )
  }

  // Printable chars shrink to `"a"`, so either of these could be valid.
  test_error_message.shrunk_value(msg)
  |> should_be_one_of(["!", "}"])
}

// TODO: the edge conditions don't matter -- test if the distribution is approximately uniform
pub fn uniform_character__test() {
  qcheck.run(
    qcheck.default_config(),
    qcheck.uniform_codepoint(),
    // TODO this test is basically pointless.
    assert_has_one_codepoint_in_range(_, 0x0000, 0x10FFFF),
  )
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn uniform_character__failures_shink_ok__test() -> Nil {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      qcheck.default_config(),
      qcheck.uniform_codepoint(),
      assert_has_one_codepoint_in_range(_, 2, 253),
    )
  }

  let s =
    test_error_message.shrunk_value(msg)
    |> string.replace(each: "\"", with: "")

  // `uniform_codepoint` shrinks towards `"a"`, so either of these could be valid.
  let check =
    int_parse_exn(s) == 1
    || int_parse_exn(s) == 254
    // Technically, this comes from a bug in the `string.replace` function
    // above, OR potentially in the shrinking functions.  For now, we stick this
    // in.  See notes for more info.
    || s == "\\u{0001}"

  should.be_true(check)
}

pub fn alphabetic_character__test() {
  use s <- qcheck.run(
    qcheck.default_config(),
    qcheck.alphabetic_ascii_codepoint(),
  )
  should.be_true(
    has_one_codepoint_in_range(s, int("A"), int("Z"))
    || has_one_codepoint_in_range(s, int("a"), int("z")),
  )
}

pub fn alphabetic_character__failures_shrink_ok__test() {
  // If the property is false, then we know the lowercase generator was selected
  // and that shrinks to "a".
  let expected = inspect_first_codepoint("a")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use s <- qcheck.run(
      qcheck.default_config(),
      qcheck.alphabetic_ascii_codepoint(),
    )
    assert_has_one_codepoint_in_range(s, int("A"), int("Z"))
  }

  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

pub fn alphabetic_character__failures_shrink_ok_2__test() {
  // If the property is false, then we know the uppercase generator was selected
  // and that shrinks to "Z".
  let expected = inspect_first_codepoint("Z")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      qcheck.default_config(),
      qcheck.alphabetic_ascii_codepoint(),
      assert_has_one_codepoint_in_range(_, int("a"), int("z")),
    )
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

pub fn alphanumeric_character__test() {
  use s <- qcheck.run(
    qcheck.default_config(),
    qcheck.alphanumeric_ascii_codepoint(),
  )
  should.be_true(
    has_one_codepoint_in_range(s, int("A"), int("Z"))
    || has_one_codepoint_in_range(s, int("a"), int("z"))
    || has_one_codepoint_in_range(s, int("0"), int("9")),
  )
}

// TODO: The shrink tests are all broken on javascript because the test error
// messages are platform dependent.

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn alphanumeric_character__failures_shrink_ok__test() -> Nil {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use _ <- qcheck.run(
      qcheck.default_config(),
      qcheck.alphanumeric_ascii_codepoint(),
    )
    should.be_true(False)
  }

  // Depending on the selected generator, any of these could be the shrink
  // target.
  test_error_message.shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9"])
}

pub fn character_from__test() {
  use s <- qcheck.run(
    qcheck.default_config(),
    qcheck.codepoint_from_strings("b", ["c", "x", "y", "z"]),
  )
  case string.from_utf_codepoints([s]) {
    "b" -> should.be_true(True)
    "c" -> should.be_true(True)
    "x" -> should.be_true(True)
    "y" -> should.be_true(True)
    "z" -> should.be_true(True)
    _ -> should.be_true(False)
  }
}

pub fn character_from__failures_shrink_ok__test() {
  let expected = string.to_utf_codepoints("b") |> hd_exn |> string.inspect

  let assert Error(msg) = {
    use <- test_error_message.rescue
    use s <- qcheck.run(
      qcheck.default_config(),
      qcheck.codepoint_from_strings("b", ["c", "x", "y", "z"]),
    )
    should.equal(string.to_utf_codepoints("q"), [s])
  }
  test_error_message.shrunk_value(msg)
  |> should.equal(expected)
}

pub fn codepoint_from_strings__doesnt_crash_on_multicodepoint_chars__test() {
  let e_accent = "é"
  let assert True = e_accent == "\u{0065}\u{0301}"
  use _ <- qcheck.run(
    qcheck.default_config(),
    qcheck.codepoint_from_strings(e_accent, [e_accent]),
  )
  should.be_true(True)
}

pub fn whitespace_character__test() {
  use codepoint <- qcheck.run(
    qcheck.default_config(),
    qcheck.ascii_whitespace_codepoint(),
  )
  case string.utf_codepoint_to_int(codepoint) {
    // Horizontal tab
    9 -> should.be_true(True)
    // Line feed
    10 -> should.be_true(True)
    // Vertical tab
    11 -> should.be_true(True)
    // Form feed
    12 -> should.be_true(True)
    // Carriage return
    13 -> should.be_true(True)
    // Space
    32 -> should.be_true(True)
    _ -> should.be_true(False)
  }
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn whitespace_character__failures_shrink_ok__test() -> Nil {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use codepoint <- qcheck.run(
      qcheck.default_config(),
      qcheck.ascii_whitespace_codepoint(),
    )
    case string.utf_codepoint_to_int(codepoint) {
      // Horizontal tab
      9 -> should.be_true(True)
      // Line feed
      10 -> should.be_true(False)
      // Vertical tab
      11 -> should.be_true(True)
      // Form feed
      12 -> should.be_true(True)
      // Carriage return
      13 -> should.be_true(False)
      // Space
      32 -> should.be_true(False)
      _ -> should.be_true(False)
    }
  }

  test_error_message.shrunk_value(msg)
  |> should_be_one_of(["\n", "\r"])
}

pub fn printable_character__test() {
  use s <- qcheck.run(
    qcheck.default_config(),
    qcheck.printable_ascii_codepoint(),
  )
  should.be_true(
    has_one_codepoint_in_range(s, int("A"), int("Z"))
    || has_one_codepoint_in_range(s, int("a"), int("z"))
    || has_one_codepoint_in_range(s, int("0"), int("9"))
    || has_one_codepoint_in_range(s, int(" "), int("~")),
  )
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn printable_character__failures_shrink_ok__test() -> Nil {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use _ <- qcheck.run(
      qcheck.default_config(),
      qcheck.printable_ascii_codepoint(),
    )
    should.be_true(False)
  }

  // Depending on the selected generator, any of these could be the shrink
  // target.
  test_error_message.shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9", " "])
}

pub fn char__test() {
  qcheck.run(
    qcheck.default_config(),
    qcheck.codepoint(),
    assert_has_one_codepoint_in_range(_, 0x0000, 0x10FFFF),
  )
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn char__failures_shrink_ok__test() -> Nil {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    use _ <- qcheck.run(qcheck.default_config(), qcheck.codepoint())
    should.be_true(False)
  }

  // Depending on the selected generator, any of these could be the shrink
  // target.
  test_error_message.shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9", " ", "\u{0000}", "\u{00FF}"])
}

// MARK: utils
//
//

fn int(c) {
  string.to_utf_codepoints(c)
  |> list.first
  |> ok_exn
  |> string.utf_codepoint_to_int
}

fn should_be_one_of(x, strings) {
  let x =
    int_parse_exn(x)
    |> utf_codepoint_exn
    |> list_return
    |> string.from_utf_codepoints

  let assert Ok(_) = strings |> list.find(one_that: fn(el) { el == x })

  Nil
}

fn utf_codepoint_exn(n) {
  let assert Ok(cp) = string.utf_codepoint(n)

  cp
}

fn list_return(a) {
  [a]
}

fn ok_exn(result) {
  let assert Ok(x) = result

  x
}

fn hd_exn(l: List(a)) -> a {
  case l {
    [h, ..] -> h
    [] -> panic as "no head"
  }
}

/// This seemingly nonsensical function is check against error messages.
///
fn inspect_first_codepoint(string: String) -> String {
  string.to_utf_codepoints(string) |> hd_exn |> string.inspect
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
fn int_parse_exn(string: String) -> Int {
  let assert Ok(int) = int.parse(string)
  int
}
