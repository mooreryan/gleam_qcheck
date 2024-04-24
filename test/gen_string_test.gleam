import gleam/regex
import gleam/string
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config

pub fn string_base__test() {
  let assert Ok(all_letters) =
    regex.compile(
      "^[a-z]+$",
      regex.Options(case_insensitive: False, multi_line: False),
    )

  let has_only_a_through_z = fn(s) { regex.check(all_letters, s) }

  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_base(
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

pub fn string_base__failure_doesnt_mess_up_shrinks__test() {
  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_base(
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

pub fn string_base__shrinks_okay_2__test() {
  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_base(
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

pub fn string_base__shrinks_okay__test() {
  qtest.run(
    config: qtest_config.default(),
    // a - z
    generator: generator.string_base(
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
