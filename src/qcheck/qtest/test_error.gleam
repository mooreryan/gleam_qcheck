//// Internal functions for raising exceptions with okay error messages.
//// 
//// This module is internal/private.

import gleam/string

pub opaque type TestError(a) {
  TestError(original_value: a, shrunk_value: a, shrink_steps: Int)
}

pub opaque type TestErrorDisplay {
  TestErrorDisplay(String)
}

pub fn new(
  original_value orig: a,
  shrunk_value shrunk: a,
  shrink_steps steps: Int,
) -> TestError(a) {
  TestError(original_value: orig, shrunk_value: shrunk, shrink_steps: steps)
}

fn to_string(test_error: TestError(a)) -> String {
  "TestError[original_value: "
  <> string.inspect(test_error.original_value)
  <> "; shrunk_value: "
  <> string.inspect(test_error.shrunk_value)
  <> "; shrink_steps: "
  <> string.inspect(test_error.shrink_steps)
  <> ";]"
}

fn display(test_error: TestError(a)) -> TestErrorDisplay {
  test_error
  |> to_string
  |> TestErrorDisplay
}

/// Use the output of this function for `panic`s inside of the property and
/// shrink runners.
pub fn new_string_repr(
  original_value orig: a,
  shrunk_value shrunk: a,
  shrink_steps steps: Int,
) -> TestErrorDisplay {
  new(original_value: orig, shrunk_value: shrunk, shrink_steps: steps)
  |> to_string
  |> TestErrorDisplay
}

@external(erlang, "qcheck_ffi", "fail")
@external(javascript, "../../qcheck_ffi.mjs", "fail")
fn do_fail(msg: String) -> a

fn fail(test_error_display: TestErrorDisplay) -> a {
  let TestErrorDisplay(msg) = test_error_display

  do_fail(msg)
}

// If this returned an opaque Exn type then you couldn't mess up the
// `test_error_message.rescue` call later, but it could potentially conflict
// with non-gleeunit test frameworks, depending on how they deal with
// exceptions.
pub fn failwith(
  original_value original_value: a,
  shrunk_value shrunk_value: a,
  shrink_steps shrink_steps: Int,
) -> b {
  new(
    original_value: original_value,
    shrunk_value: shrunk_value,
    shrink_steps: shrink_steps,
  )
  |> display
  |> fail
}
