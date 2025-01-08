import birdie
import gleam/bit_array
import gleam/list
import gleam/string
import qcheck

// MARK: Bit arrays

// Note: non-byte-aligned bit arrays do not work on the JS target.  So replace
// these tests with "do nothing" externals.

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array__smoke_test() -> Nil {
  use bits <- qcheck.given(qcheck.bit_array())
  bit_array.bit_size(bits) >= 0
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_non_empty__doesnt_generate_empty_arrays__test() -> Nil {
  use bits <- qcheck.given(qcheck.bit_array_non_empty())
  bit_array.bit_size(bits) >= 1
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_with_size_from__makes_arrays_with_valid_size__test() -> Nil {
  use bits <- qcheck.given(
    qcheck.bit_array_with_size_from(qcheck.int_uniform_inclusive(2, 5)),
  )
  let bit_size = bit_array.bit_size(bits)
  2 <= bit_size && bit_size <= 5
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_with_size__makes_arrays_with_valid_size__test() -> Nil {
  use bits <- qcheck.given(qcheck.bit_array_with_size(5))
  bit_array.bit_size(bits) == 5
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_shrinking__test() -> Nil {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.bit_array_with_size_from(qcheck.int_uniform_inclusive(1, 3)),
      qcheck.seed_new(2),
    )

  tree
  |> qcheck.tree_to_string(string.inspect)
  |> birdie.snap("bit_array_shrinking__test")
}

// MARK: Bit arrays (UTF-8)

pub fn bit_array_utf8__generates_valid_utf8_bit_arrays__test() {
  use utf8_bytes <- qcheck.given(qcheck.bit_array_utf8())
  bit_array.is_utf8(utf8_bytes)
}

pub fn bit_array_utf8_non_empty__generates_valid_non_empty_utf8_bit_arrays__test() {
  use utf8_bytes <- qcheck.given(qcheck.bit_array_utf8_non_empty())
  bit_array.is_utf8(utf8_bytes) && bit_array.bit_size(utf8_bytes) >= 8
}

pub fn bit_array_utf8_with_size__generates_valid_utf8_bit_arrays_with_given_num_codepoints__test() {
  let expected_num_codepoints = 5
  use utf8_bytes <- qcheck.given(qcheck.bit_array_utf8_with_size(
    expected_num_codepoints,
  ))

  let is_valid_utf8 = bit_array.is_utf8(utf8_bytes)

  let codepoints = utf8_bytes_to_codepoints(utf8_bytes)

  let correct_num_codepoints =
    list.length(codepoints) == expected_num_codepoints

  is_valid_utf8 && correct_num_codepoints
}

pub fn bit_array_utf8_with_size_from__generates_valid_utf8_bit_arrays_with_correct_num_codepoints__test() {
  let expected_min_codepoints = 2
  let expected_max_codepoints = 5

  use utf8_bytes <- qcheck.given(
    qcheck.bit_array_utf8_with_size_from(qcheck.int_uniform_inclusive(
      expected_min_codepoints,
      expected_max_codepoints,
    )),
  )

  let is_valid_utf8 = bit_array.is_utf8(utf8_bytes)

  let codepoints = utf8_bytes_to_codepoints(utf8_bytes)

  let num_codepoints = list.length(codepoints)

  let correct_num_codepoints =
    expected_min_codepoints <= num_codepoints
    && num_codepoints <= expected_max_codepoints

  is_valid_utf8 && correct_num_codepoints
}

// MARK: Bit arrays (byte-aligned)

pub fn bit_array_byte_aligned__bit_size_is_always_divisible_by_8__test() {
  use bytes <- qcheck.given(qcheck.bit_array_byte_aligned())
  bit_array.bit_size(bytes) % 8 == 0
}

pub fn bit_array_byte_aligned_non_empty__bit_size_is_always_divisible_by_8__test() {
  use bytes <- qcheck.given(qcheck.bit_array_byte_aligned_non_empty())
  bit_array.bit_size(bytes) % 8 == 0 && bit_array.bit_size(bytes) > 0
}

pub fn bit_array_byte_aligned_with_size_from__makes_arrays_with_valid_size__test() {
  use bits <- qcheck.given(
    qcheck.bit_array_byte_aligned_with_size_from(qcheck.int_uniform_inclusive(
      2,
      5,
    )),
  )
  let byte_size = bit_array.byte_size(bits)
  2 <= byte_size && byte_size <= 5
}

pub fn bit_array_byte_aligned_with_size__makes_arrays_with_valid_size__test() {
  use bits <- qcheck.given(qcheck.bit_array_byte_aligned_with_size(5))
  bit_array.byte_size(bits) == 5
}

// MARK: Negative sizes

pub fn bit_array_with_size_from__negative_sizes_yield_empty_bit_arrays__test() {
  use bits <- qcheck.given(qcheck.bit_array_with_size_from(negative_numbers()))
  bit_array.bit_size(bits) == 0
}

pub fn bit_array_byte_aligned_with_size_from__negative_sizes_yield_empty_bit_arrays__test() {
  use bits <- qcheck.given(
    qcheck.bit_array_byte_aligned_with_size_from(negative_numbers()),
  )
  bit_array.bit_size(bits) == 0
}

pub fn bit_array_utf8_with_size_from__negative_sizes_yield_empty_bit_arrays__test() {
  use bits <- qcheck.given(
    qcheck.bit_array_utf8_with_size_from(negative_numbers()),
  )
  bit_array.bit_size(bits) == 0
}

// MARK: Utils

fn utf8_bytes_to_codepoints(utf8_bytes) {
  utf8_bytes
  |> bit_array.to_string
  |> ok_exn
  |> string.to_utf_codepoints
}

fn ok_exn(x) {
  let assert Ok(x) = x
  x
}

fn negative_numbers() -> qcheck.Generator(Int) {
  qcheck.int_uniform_inclusive(-1_000_000, -1)
}
