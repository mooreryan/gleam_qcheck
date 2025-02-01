import gleam/list
import gleam/string
import gleeunit/should
import qcheck
import qcheck/test_error_message

pub fn bounded_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.bounded_character(500, 1000),
    property: fn(s) {
      let codepoints = string.to_utf_codepoints(s)

      // There should be only a single codepoint generated.
      let assert [codepoint] = codepoints

      let n = string.utf_codepoint_to_int(codepoint)

      500 <= n && n <= 1000
    },
  )
}

pub fn bounded_character__ranges_that_include_invalid_codepoints__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(10_000),
    generator: qcheck.bounded_character(55_200, 58_000),
    property: fn(s) {
      let codepoints = string.to_utf_codepoints(s)

      // There should be only a single codepoint generated.
      let assert [codepoint] = codepoints

      let n = string.utf_codepoint_to_int(codepoint)

      55_200 <= n && n <= 58_000
    },
  )
}

pub fn bounded_character__low_greater_than_hi__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(10_000),
    generator: qcheck.bounded_character(70, 65),
    property: fn(s) {
      let codepoints = string.to_utf_codepoints(s)

      // There should be only a single codepoint generated.
      let assert [codepoint] = codepoints

      let n = string.utf_codepoint_to_int(codepoint)

      65 <= n && n <= 70
    },
  )
}

pub fn bounded_character__codepoints_out_of_range__test() {
  qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(10_000),
    generator: qcheck.bounded_character(-2_000_000, 2_000_000),
    property: it_doesnt_crash,
  )
}

fn it_doesnt_crash(_) {
  True
}

pub fn bounded_character__failures_shink_ok__test() {
  let expected =
    500
    |> utf_codepoint_exn
    |> list_return
    |> string.from_utf_codepoints
    |> string.inspect

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.bounded_character(500, 1000),
      property: fn(s) {
        let codepoints = string.to_utf_codepoints(s)

        // There should be only a single codepoint generated.
        let assert [codepoint] = codepoints

        let n = string.utf_codepoint_to_int(codepoint)

        600 <= n && n <= 900
      },
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

fn has_one_codepoint_in_range(s: String, low: Int, high: Int) -> Bool {
  let codepoints = string.to_utf_codepoints(s)

  // There should be only a single codepoint generated.
  let assert [codepoint] = codepoints

  let n = string.utf_codepoint_to_int(codepoint)

  low <= n && n <= high
}

pub fn uppercase_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.uppercase_character(),
    property: has_one_codepoint_in_range(_, int("A"), int("Z")),
  )
}

pub fn uppercase_character__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = string.inspect("Z")

  let assert Error(msg) = {
    use <- test_error_message.rescue

    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.uppercase_character(),
      property: has_one_codepoint_in_range(_, int("A") + 2, int("Z") - 2),
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn lowercase_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.lowercase_character(),
    property: has_one_codepoint_in_range(_, int("a"), int("z")),
  )
}

pub fn lowercase_character__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = string.inspect("a")

  let assert Error(msg) = {
    use <- test_error_message.rescue

    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.lowercase_character(),
      property: has_one_codepoint_in_range(_, int("a") + 2, int("z") - 2),
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn digit_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.digit_character(),
    property: has_one_codepoint_in_range(_, int("0"), int("9")),
  )
}

pub fn digit_character__failures_shink_ok__test() {
  // "9" is less than "a" => "9" is "closer" to "a" so that is the shrink
  // target.
  let expected = string.inspect("9")

  let assert Error(msg) = {
    use <- test_error_message.rescue

    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.digit_character(),
      property: has_one_codepoint_in_range(_, int("0") + 2, int("9") - 2),
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn uniform_printable_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.uniform_printable_character(),
    property: has_one_codepoint_in_range(_, int(" "), int("~")),
  )
}

pub fn uniform_printable_character__failures_shink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.uniform_printable_character(),
      property: has_one_codepoint_in_range(_, int(" ") + 2, int("~") - 2),
    )
  }

  // Printable chars shrink to `"a"`, so either of these could be valid.
  test_error_message.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["!", "}"])
}

pub fn uniform_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.uniform_character(),
    property: has_one_codepoint_in_range(_, 0, 255),
  )
}

pub fn uniform_character__failures_shink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.uniform_character(),
      property: has_one_codepoint_in_range(_, 2, 253),
    )
  }

  // `uniform_character` shrinks towards `"a"`, so either of these could be valid.
  let s =
    test_error_message.test_error_message_shrunk_value(msg)
    |> string.replace(each: "\"", with: "")

  should.be_true(
    int(s) == 1
    || int(s) == 254
    // Technically, this comes from a bug in the `string.replace` function
    // above, OR potentially in the shrinking functions.  For now, we stick this
    // in.  See notes for more info.
    || s == "\\u{0001}",
  )
}

pub fn alphabetic_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.alphabetic_character(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
    },
  )
}

pub fn alphabetic_character__failures_shrink_ok__test() {
  // If the property is false, then we know the lowercase generator was selected
  // and that shrinks to "a".
  let expected = string.inspect("a")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.alphabetic_character(),
      property: fn(s) { has_one_codepoint_in_range(s, int("A"), int("Z")) },
    )
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn alphabetic_character__failures_shrink_ok_2__test() {
  // If the property is false, then we know the uppercase generator was selected
  // and that shrinks to "Z".
  let expected = string.inspect("Z")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.alphabetic_character(),
      property: fn(s) { has_one_codepoint_in_range(s, int("a"), int("z")) },
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn alphanumeric_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.alphanumeric_character(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
      || has_one_codepoint_in_range(s, int("0"), int("9"))
    },
  )
}

pub fn alphanumeric_character__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.alphanumeric_character(),
      property: fn(_) { False },
    )
  }

  // Depending on the selected generator, any of these could be the shrink
  // target.
  test_error_message.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9"])
}

pub fn character_from__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.character_from("b", ["c", "x", "y", "z"]),
    property: fn(s) {
      case s {
        "b" -> True
        "c" -> True
        "x" -> True
        "y" -> True
        "z" -> True
        _ -> False
      }
    },
  )
}

pub fn character_from__failures_shrink_ok__test() {
  let expected = string.inspect("b")

  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.character_from("b", ["c", "x", "y", "z"]),
      property: fn(s) { s == "q" },
    )
  }
  test_error_message.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn character_from__doesnt_crash_on_multicodepoint_chars__test() {
  let e_accent = "é"
  let assert True = e_accent == "\u{0065}\u{0301}"
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.character_from(e_accent, [e_accent]),
    property: fn(_) { True },
  )
}

pub fn whitespace_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.whitespace_character(),
    property: fn(c) {
      case int(c) {
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
    },
  )
}

pub fn whitespace_character__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.whitespace_character(),
      property: fn(c) {
        case int(c) {
          // Horizontal tab
          9 -> True
          // Line feed
          10 -> False
          // Vertical tab
          11 -> True
          // Form feed
          12 -> True
          // Carriage return
          13 -> False
          // Space
          32 -> False
          _ -> False
        }
      },
    )
  }

  test_error_message.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["\n", "\r"])
}

pub fn printable_character__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.printable_character(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
      || has_one_codepoint_in_range(s, int("0"), int("9"))
      || has_one_codepoint_in_range(s, int(" "), int("~"))
    },
  )
}

pub fn printable_character__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.printable_character(),
      property: fn(_) { False },
    )
  }

  // Depending on the selected generator, any of these could be the shrink
  // target.
  test_error_message.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9", " "])
}

pub fn unicode_character__generates_a_char_with_a_single_codepoint__test() {
  use char <- qcheck.given(qcheck.unicode_character())
  let codepoints = string.to_utf_codepoints(char)
  list.length(codepoints) == 1
}

pub fn char__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.character(),
    property: has_one_codepoint_in_range(_, 0, 255),
  )
}

pub fn char__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- test_error_message.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.character(),
      property: fn(_) { False },
    )
  }

  // Depending on the selected generator, any of these could be the shrink
  // target.
  test_error_message.test_error_message_shrunk_value(msg)
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
  let assert Ok(_) =
    strings
    |> list.map(string.inspect)
    |> list.find(one_that: fn(el) { el == x })

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
