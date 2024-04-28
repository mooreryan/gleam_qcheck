import gleam/string
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/utils

fn int(c) {
  utils.char_to_int(c)
}

pub fn char_uniform_inclusive__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_uniform_inclusive(500, 1000),
    property: fn(s) {
      let codepoints = string.to_utf_codepoints(s)

      // There should be only a single codepoint generated.
      let assert [codepoint] = codepoints

      let n = string.utf_codepoint_to_int(codepoint)

      500 <= n && n <= 1000
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn char_uniform_inclusive__failures_shink_ok__test() {
  let expected =
    500
    |> utils.utf_codepoint_exn
    |> utils.list_return
    |> string.from_utf_codepoints
    |> Error

  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_uniform_inclusive(500, 1000),
    property: fn(s) {
      let codepoints = string.to_utf_codepoints(s)

      // There should be only a single codepoint generated.
      let assert [codepoint] = codepoints

      let n = string.utf_codepoint_to_int(codepoint)

      600 <= n && n <= 900
    },
  )
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
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_uppercase(),
    property: has_one_codepoint_in_range(_, int("A"), int("Z")),
  )
  |> should.equal(Ok(Nil))
}

pub fn char_uppercase__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = Error("Z")

  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_uppercase(),
    property: has_one_codepoint_in_range(_, int("A") + 2, int("Z") - 2),
  )
  |> should.equal(expected)
}

pub fn char_lowercase__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_lowercase(),
    property: has_one_codepoint_in_range(_, int("a"), int("z")),
  )
  |> should.equal(Ok(Nil))
}

pub fn char_lowercase__failures_shink_ok__test() {
  // "Z" is less than "a" => "Z" is "closer" to "a" so that is the shrink
  // target.
  let expected = Error("a")

  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_lowercase(),
    property: has_one_codepoint_in_range(_, int("a") + 2, int("z") - 2),
  )
  |> should.equal(expected)
}

pub fn char_digit__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_digit(),
    property: has_one_codepoint_in_range(_, int("0"), int("9")),
  )
  |> should.equal(Ok(Nil))
}

pub fn char_digit__failures_shink_ok__test() {
  // "9" is less than "a" => "9" is "closer" to "a" so that is the shrink
  // target.
  let expected = Error("9")

  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_digit(),
    property: has_one_codepoint_in_range(_, int("0") + 2, int("9") - 2),
  )
  |> should.equal(expected)
}

pub fn char_print_uniform__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_print_uniform(),
    property: has_one_codepoint_in_range(_, int(" "), int("~")),
  )
  |> should.equal(Ok(Nil))
}

pub fn char_print_uniform__failures_shink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char_print_uniform(),
      property: has_one_codepoint_in_range(_, int(" ") + 2, int("~") - 2),
    )

  // Printable chars shrink to `"a"`, so either of these could be valid.
  case result {
    Error("!") -> True
    Error("}") -> True
    _ -> False
  }
  |> should.be_true
}

pub fn char_uniform__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_uniform(),
    property: has_one_codepoint_in_range(_, 0, 255),
  )
  |> should.equal(Ok(Nil))
}

pub fn char_uniform__failures_shink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char_uniform(),
      property: has_one_codepoint_in_range(_, 2, 253),
    )

  // `char_uniform` shrinks towards `"a"`, so either of these could be valid.
  case result {
    Error(c) -> int(c) == 1 || int(c) == 254
    _ -> False
  }
  |> should.be_true
}

pub fn char_alpha__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_alpha(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn char_alpha__failures_shrink_ok__test() {
  // If the property is false, then we know the lowercase generator was selected
  // and that shrinks to "a".
  let expected = Error("a")

  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_alpha(),
    property: fn(s) { has_one_codepoint_in_range(s, int("A"), int("Z")) },
  )
  |> should.equal(expected)
}

pub fn char_alpha__failures_shrink_ok_2__test() {
  // If the property is false, then we know the uppercase generator was selected
  // and that shrinks to "Z".
  let expected = Error("Z")

  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_alpha(),
    property: fn(s) { has_one_codepoint_in_range(s, int("a"), int("z")) },
  )
  |> should.equal(expected)
}

pub fn char_alpha_numeric__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_alpha_numeric(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
      || has_one_codepoint_in_range(s, int("0"), int("9"))
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn char_alpha_numeric__failures_shrink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char_alpha_numeric(),
      property: fn(_) { False },
    )

  // Depending on the selected generator, any of these could be the shrink 
  // target.
  case result {
    Error("a") -> True
    Error("Z") -> True
    Error("9") -> True
    _ -> False
  }
  |> should.be_true
}

pub fn char_from_list__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_from_list(["b", "c", "x", "y", "z"]),
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
  |> should.equal(Ok(Nil))
}

pub fn char_from_list__failures_shrink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char_from_list(["b", "c", "x", "y", "z"]),
      property: fn(s) { s == "q" },
    )

  result
  |> should.equal(Error("b"))
}

pub fn char_whitespace__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_whitespace(),
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
  |> should.equal(Ok(Nil))
}

pub fn char_whitespace__failures_shrink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char_whitespace(),
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

  case result {
    Error("\n") -> True
    Error("\r") -> True
    _ -> False
  }
  |> should.be_true
}

pub fn char_print__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char_print(),
    property: fn(s) {
      has_one_codepoint_in_range(s, int("A"), int("Z"))
      || has_one_codepoint_in_range(s, int("a"), int("z"))
      || has_one_codepoint_in_range(s, int("0"), int("9"))
      || has_one_codepoint_in_range(s, int(" "), int("~"))
    },
  )
  |> should.equal(Ok(Nil))
}

pub fn char_print__failures_shrink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char_print(),
      property: fn(_) { False },
    )

  // Depending on the selected generator, any of these could be the shrink 
  // target.
  case result {
    Error("a") -> True
    Error("Z") -> True
    Error("9") -> True
    Error(" ") -> True
    _ -> False
  }
  |> should.be_true
}

pub fn char__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.char(),
    property: has_one_codepoint_in_range(_, 0, 255),
  )
  |> should.equal(Ok(Nil))
}

pub fn char__failures_shrink_ok__test() {
  let result =
    qtest.run(
      config: qtest_config.default(),
      generator: generator.char(),
      property: fn(_) { False },
    )

  // Depending on the selected generator, any of these could be the shrink 
  // target.
  case result {
    Error("a") -> True
    Error("Z") -> True
    Error("9") -> True
    Error(" ") -> True
    // The generators that return edges don't shrink at all.
    Error("\u{0000}") -> True
    Error("\u{00FF}") -> True
    Error(_) -> False
    Ok(Nil) -> False
  }
  |> should.be_true
}
