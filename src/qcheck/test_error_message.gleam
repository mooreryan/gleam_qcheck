//// This is an internal module used for printing qcheck test errors.
//// 

import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string

pub opaque type TestErrorMessage {
  TestErrorMessage(
    original_value: String,
    shrunk_value: String,
    shrink_steps: String,
  )
}

pub fn test_error_message_shrunk_value(msg: TestErrorMessage) -> String {
  msg.shrunk_value
}

fn new_test_error_message(
  original_value original_value: String,
  shrunk_value shrunk_value: String,
  shrink_steps shrink_steps: String,
) -> TestErrorMessage {
  TestErrorMessage(
    original_value: original_value,
    shrunk_value: shrunk_value,
    shrink_steps: shrink_steps,
  )
}

fn regexp_first_submatch(
  pattern pattern: String,
  in value: String,
) -> Result(String, String) {
  regexp.from_string(pattern)
  // Convert regexp.CompileError to a String
  |> result.map_error(string.inspect)
  // Apply the regular expression
  |> result.map(regexp.scan(_, value))
  // We should see only a single match
  |> result.then(fn(matches) {
    case matches {
      [match] -> Ok(match)
      _ -> Error("expected exactly one match")
    }
  })
  // We should see only a single successful submatch
  |> result.then(fn(match) {
    let regexp.Match(_content, submatches) = match

    case submatches {
      [Some(submatch)] -> Ok(submatch)
      _ -> Error("expected exactly one submatch")
    }
  })
}

/// Mainly for asserting values in qcheck internal tests.
/// 
fn test_error_message_get_original_value(
  test_error_str: String,
) -> Result(String, String) {
  regexp_first_submatch(pattern: "original_value: (.+?);", in: test_error_str)
}

/// Mainly for asserting values in qcheck internal tests.
/// 
fn test_error_message_get_shrunk_value(
  test_error_str: String,
) -> Result(String, String) {
  regexp_first_submatch(pattern: "shrunk_value: (.+?);", in: test_error_str)
}

/// Mainly for asserting values in qcheck internal tests.
/// 
fn test_error_message_get_shrink_steps(
  test_error_str: String,
) -> Result(String, String) {
  regexp_first_submatch(pattern: "shrink_steps: (.+?);", in: test_error_str)
}

/// This function should only be called to rescue a function that may call
/// `failwith` at some point to raise an exception.  It will likely 
/// raise otherwise.
/// 
/// This function is internal.  Breaking changes may occur without a major 
/// version update.
/// 
pub fn rescue(thunk: fn() -> a) -> Result(a, TestErrorMessage) {
  case rescue_error(thunk) {
    Ok(a) -> Ok(a)
    Error(err) -> {
      // If this assert causes a panic, then you have an implementation error.
      let assert Ok(test_error_message) = {
        use original_value <- result.then(test_error_message_get_original_value(
          err,
        ))
        use shrunk_value <- result.then(test_error_message_get_shrunk_value(err))
        use shrink_steps <- result.then(test_error_message_get_shrink_steps(err))

        Ok(new_test_error_message(
          original_value: original_value,
          shrunk_value: shrunk_value,
          shrink_steps: shrink_steps,
        ))
      }

      Error(test_error_message)
    }
  }
}

@external(erlang, "qcheck_ffi", "rescue_error")
@external(javascript, "../qcheck_ffi.mjs", "rescue_error")
fn rescue_error(f: fn() -> a) -> Result(a, String)
