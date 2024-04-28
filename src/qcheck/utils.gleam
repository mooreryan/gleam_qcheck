//// This module provides internal utility functions and should be considered 
//// private.

import gleam/list
import gleam/string

pub fn list_return(a) {
  [a]
}

pub fn ok_exn(result) {
  let assert Ok(x) = result

  x
}

pub fn list_cons(x, xs) {
  [x, ..xs]
}

pub fn utf_codepoint_exn(n) {
  let assert Ok(cp) = string.utf_codepoint(n)

  cp
}

// TODO: Could this be simplified?
pub fn int_to_char(n: Int) -> String {
  n
  |> string.utf_codepoint
  |> ok_exn
  |> list_return
  |> string.from_utf_codepoints
}

pub fn char_to_int(c: String) -> Int {
  string.to_utf_codepoints(c)
  |> list.first
  |> ok_exn
  |> string.utf_codepoint_to_int
}

// Assumes that the args are properly ordered.
pub fn pick_origin_within_range(low: Int, high: Int, goal goal: Int) {
  case low > goal {
    True -> low
    False ->
      case high < goal {
        True -> high
        False -> goal
      }
  }
}
