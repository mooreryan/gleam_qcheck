import gleam/bit_array
import gleam/dynamic
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import qcheck/internal/gleam_panic.{type GleamPanic}

pub fn test_failed_message(
  error error: dynamic.Dynamic,
  original_value original_value: a,
  shrunk_value shrunk_value: a,
  shrink_steps shrink_steps: Int,
) -> String {
  case gleam_panic.from_dynamic(error) {
    Ok(error) -> {
      let src = option.from_result(read_file(error.file))
      format_gleam_error(
        error,
        src,
        original_value:,
        shrunk_value:,
        shrink_steps:,
      )
    }
    Error(_) -> format_unknown(error)
  }
}

fn format_unknown(error: dynamic.Dynamic) -> String {
  string.concat([
    "An unexpected error occurred:\n",
    "\n",
    "  " <> string.inspect(error) <> "\n",
  ])
}

fn format_gleam_error(
  error: GleamPanic,
  src: Option(BitArray),
  original_value original_value: a,
  shrunk_value shrunk_value: a,
  shrink_steps shrink_steps: Int,
) -> String {
  let location = grey(error.file <> ":" <> int.to_string(error.line))

  let panic_info = case error.kind {
    gleam_panic.Panic -> {
      [
        bold(yellow("\nqcheck panic")) <> " " <> location <> "\n",
        cyan(" info") <> ": " <> error.message <> "\n",
      ]
    }

    gleam_panic.Todo -> {
      [
        bold(yellow("\nqcheck todo")) <> " " <> location <> "\n",
        cyan(" info") <> ": " <> error.message <> "\n",
      ]
    }

    gleam_panic.Assert(start:, end:, kind:, ..) -> {
      [
        bold(yellow("\nqcheck assert")) <> " " <> location <> "\n",
        code_snippet(src, start, end),
        assert_info(kind),
        cyan(" info") <> ": " <> error.message <> "\n",
      ]
    }

    gleam_panic.LetAssert(start:, end:, value:, ..) -> {
      [
        bold(yellow("\nqcheck let assert")) <> " " <> location <> "\n",
        code_snippet(src, start, end),
        cyan("value") <> ": " <> string.inspect(value) <> "\n",
        cyan(" info") <> ": " <> error.message <> "\n",
      ]
    }
  }

  let shrink_info = [
    bold(yellow("qcheck shrinks\n")),
    cyan(" orig") <> ": " <> string.inspect(original_value) <> "\n",
    cyan("shrnk") <> ": " <> string.inspect(shrunk_value) <> "\n",
    cyan("steps") <> ": " <> int.to_string(shrink_steps) <> "\n",
  ]

  list.flatten([
    ["a property was falsified!"],
    panic_info,
    shrink_info,
  ])
  |> string.concat
}

fn assert_info(kind: gleam_panic.AssertKind) -> String {
  case kind {
    gleam_panic.BinaryOperator(left:, right:, ..) -> {
      string.concat([
        assert_value(" left", left),
        assert_value("right", right),
      ])
    }

    gleam_panic.FunctionCall(arguments:) -> {
      arguments
      |> list.index_map(fn(e, i) {
        let number = string.pad_start(int.to_string(i), 5, " ")
        assert_value(number, e)
      })
      |> string.concat
    }

    gleam_panic.OtherExpression(..) -> ""
  }
}

fn assert_value(name: String, value: gleam_panic.AssertedExpression) -> String {
  cyan(name) <> ": " <> inspect_value(value) <> "\n"
}

fn inspect_value(value: gleam_panic.AssertedExpression) -> String {
  case value.kind {
    gleam_panic.Unevaluated -> grey("unevaluated")
    gleam_panic.Literal(..) -> grey("literal")
    gleam_panic.Expression(value:) -> string.inspect(value)
  }
}

fn code_snippet(src: Option(BitArray), start: Int, end: Int) -> String {
  {
    use src <- result.try(option.to_result(src, Nil))
    use snippet <- result.try(bit_array.slice(src, start, end - start))
    use snippet <- result.try(bit_array.to_string(snippet))
    let snippet = cyan(" code") <> ": " <> snippet <> "\n"
    Ok(snippet)
  }
  |> result.unwrap("")
}

fn bold(text: String) -> String {
  "\u{001b}[1m" <> text <> "\u{001b}[22m"
}

fn cyan(text: String) -> String {
  "\u{001b}[36m" <> text <> "\u{001b}[39m"
}

fn yellow(text: String) -> String {
  "\u{001b}[33m" <> text <> "\u{001b}[39m"
}

fn grey(text: String) -> String {
  "\u{001b}[90m" <> text <> "\u{001b}[39m"
}

@external(erlang, "file", "read_file")
fn read_file(path: String) -> Result(BitArray, dynamic.Dynamic) {
  case read_file_text(path) {
    Ok(text) -> Ok(bit_array.from_string(text))
    Error(e) -> Error(e)
  }
}

@external(javascript, "./read_file_ffi.mjs", "read_file")
fn read_file_text(path: String) -> Result(String, dynamic.Dynamic)
