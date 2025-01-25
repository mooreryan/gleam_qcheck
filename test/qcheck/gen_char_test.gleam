import gleam/list
import gleam/string
import gleeunit/should
import qcheck

pub fn char_uniform_inclusive__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_uniform_inclusive(500, 1000),
    property: fn(s) {
      let codepoints = string.to_utf_codepoints(s)

      // There should be only a single codepoint generated.
      let assert [codepoint] = codepoints

      let n = string.utf_codepoint_to_int(codepoint)

      500 <= n && n <= 1000
    },
  )
}

pub fn char_uniform_inclusive__failures_shink_ok__test() {
  let expected =
    500
    |> utf_codepoint_exn
    |> list_return
    |> string.from_utf_codepoints
    |> string.inspect

  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_uniform_inclusive(500, 1000),
      property: fn(s) {
        let codepoints = string.to_utf_codepoints(s)

        // There should be only a single codepoint generated.
        let assert [codepoint] = codepoints

        let n = string.utf_codepoint_to_int(codepoint)

        600 <= n && n <= 900
      },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

fn has_one_codepoint_in_range(s: String, low: Int, high: Int) -> Bool {
  let codepoints = string.to_utf_codepoints(s)

  // There should be only a single codepoint generated.
  let assert [codepoint] = codepoints

  let n = string.utf_codepoint_to_int(codepoint)

  low <= n && n <= high
}

pub fn char_uppercase__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_uppercase(),
    property: has_one_codepoint_in_range(_, int("A"), int("Z")),
  )
}

pub fn char_uppercase__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = string.inspect("Z")

  let assert Error(msg) = {
    use <- qcheck.rescue

    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_uppercase(),
      property: has_one_codepoint_in_range(_, int("A") + 2, int("Z") - 2),
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn char_lowercase__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_lowercase(),
    property: has_one_codepoint_in_range(_, int("a"), int("z")),
  )
}

pub fn char_lowercase__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = string.inspect("a")

  let assert Error(msg) = {
    use <- qcheck.rescue

    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_lowercase(),
      property: has_one_codepoint_in_range(_, int("a") + 2, int("z") - 2),
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn char_digit__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_digit(),
    property: has_one_codepoint_in_range(_, int("0"), int("9")),
  )
}

pub fn char_digit__failures_shink_ok__test() {
  // "9" is less than "a" => "9" is "closer" to "a" so that is the shrink
  // target.
  let expected = string.inspect("9")

  let assert Error(msg) = {
    use <- qcheck.rescue

    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_digit(),
      property: has_one_codepoint_in_range(_, int("0") + 2, int("9") - 2),
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn char_printable_uniform__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_printable_uniform(),
    property: has_one_codepoint_in_range(_, int(" "), int("~")),
  )
}

pub fn char_printable_uniform__failures_shink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_printable_uniform(),
      property: has_one_codepoint_in_range(_, int(" ") + 2, int("~") - 2),
    )
  }

  // Printable chars shrink to `"a"`, so either of these could be valid.
  qcheck.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["!", "}"])
}

pub fn char_uniform__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_uniform(),
    property: has_one_codepoint_in_range(_, 0, 255),
  )
}

pub fn char_uniform__failures_shink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_uniform(),
      property: has_one_codepoint_in_range(_, 2, 253),
    )
  }

  // `char_uniform` shrinks towards `"a"`, so either of these could be valid.
  let s =
    qcheck.test_error_message_shrunk_value(msg)
    |> string.replace(each: "\"", with: "")

  should.be_true(
    int(s) == 1
    || int(s) == 254
    // TODO
    // Technically, this comes from a bug in the `string.replace` function
    // above, OR potentially in the shrinking functions.  For now, we stick this
    // in.  See notes for more info.
    || s == "\\u{0001}",
  )
}

pub fn char_alpha__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_alpha(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
    },
  )
}

pub fn char_alpha__failures_shrink_ok__test() {
  // If the property is false, then we know the lowercase generator was selected
  // and that shrinks to "a".
  let expected = string.inspect("a")

  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_alpha(),
      property: fn(s) { has_one_codepoint_in_range(s, int("A"), int("Z")) },
    )
  }

  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn char_alpha__failures_shrink_ok_2__test() {
  // If the property is false, then we know the uppercase generator was selected
  // and that shrinks to "Z".
  let expected = string.inspect("Z")

  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_alpha(),
      property: fn(s) { has_one_codepoint_in_range(s, int("a"), int("z")) },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn char_alpha_numeric__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_alpha_numeric(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
      || has_one_codepoint_in_range(s, int("0"), int("9"))
    },
  )
}

pub fn char_alpha_numeric__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_alpha_numeric(),
      property: fn(_) { False },
    )
  }

  // Depending on the selected generator, any of these could be the shrink 
  // target.
  qcheck.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9"])
}

pub fn char_from_list__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_from_list("b", ["c", "x", "y", "z"]),
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

pub fn char_from_list__failures_shrink_ok__test() {
  let expected = string.inspect("b")

  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_from_list("b", ["c", "x", "y", "z"]),
      property: fn(s) { s == "q" },
    )
  }
  qcheck.test_error_message_shrunk_value(msg)
  |> should.equal(expected)
}

pub fn char_whitespace__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_whitespace(),
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

pub fn char_whitespace__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_whitespace(),
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

  qcheck.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["\n", "\r"])
}

pub fn char_printable__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char_printable(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
      || has_one_codepoint_in_range(s, int("0"), int("9"))
      || has_one_codepoint_in_range(s, int(" "), int("~"))
    },
  )
}

pub fn char_printable__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char_printable(),
      property: fn(_) { False },
    )
  }

  // Depending on the selected generator, any of these could be the shrink 
  // target.
  qcheck.test_error_message_shrunk_value(msg)
  |> should_be_one_of(["a", "Z", "9", " "])
}

pub fn char_utf_codepoint__generates_a_char_with_a_single_codepoint__test() {
  use char <- qcheck.given(qcheck.char_utf_codepoint())
  let codepoints = string.to_utf_codepoints(char)
  list.length(codepoints) == 1
}

pub fn char__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.char(),
    property: has_one_codepoint_in_range(_, 0, 255),
  )
}

pub fn char__failures_shrink_ok__test() {
  let assert Error(msg) = {
    use <- qcheck.rescue
    qcheck.run(
      config: qcheck.default_config(),
      generator: qcheck.char(),
      property: fn(_) { False },
    )
  }

  // Depending on the selected generator, any of these could be the shrink 
  // target.
  qcheck.test_error_message_shrunk_value(msg)
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
