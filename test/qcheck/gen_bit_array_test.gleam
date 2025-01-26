import birdie
import gleam/bit_array
import gleam/list
import gleam/string
import qcheck
import qcheck/tree

// MARK: Bit arrays

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
pub fn bit_array_with_size_from__makes_arrays_with_valid_size_and_values__test() -> Nil {
  let bit_size = 5
  use bits <- qcheck.given(qcheck.bit_array_with_size_from(
    // Bit size 5 can encode 0-31
    qcheck.int_uniform_inclusive(1, 30),
    bit_size:,
  ))
  let assert <<value:size(bit_size)>> = bits
  let value_okay = 1 <= value && value <= 30
  bit_array.bit_size(bits) == bit_size && value_okay
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_with_size__makes_arrays_with_valid_size__test() -> Nil {
  let generator = {
    use bit_size <- qcheck.bind(qcheck.int_small_positive_or_zero())
    use bit_array <- qcheck.map(qcheck.bit_array_with_size(bit_size))
    #(bit_array, bit_size)
  }

  use #(bit_array, expected_bit_size) <- qcheck.given(generator)
  bit_array.bit_size(bit_array) == expected_bit_size
}

// NOTE: this shrinking looks weird, but it is "correct" in terms of how the
// values and sizes are generated.  The bit array generators first shrink on
// size, then on values.  But, depending on the value generator, it may generate
// values outside of the range of a "shrunk" bit array.
// 
// Here, generated values range from [3, 5], sizes range from [1, 3].  In the
// example, the first generated bit array is <<4:size(3)>>.  The value 4 will
// never shrink up to 5, and, given the way int generators work, shrinking will
// never generate values outside of the range of the generator. So shrunk values
// in all shrinks will only ever be 4 or 3.  
//
// Here is an overview of the first couple shrinks.  `size(3)` is shrunk to is
// size(1).  A value of 4 cannot be represented by one bit so it becomes 0 (4 =
// 0b100, and in 1 bit that is 0).  So rather than seeing <<4:size(1)>> you see
// <<0:size(1)>>.  The next shrink based on that one would be <<3:size(1)>>,
// because because it will shrink on values next.  Again, 3 cannot be
// represented in 1 bit (3 = 0b011 -> 1:size(1)).  So you will see
// <<1:size(1)>>.  
//
// The other shrinks follow a similar pattern.
//
@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_shrinking__test() -> Nil {
  let generator =
    qcheck.bit_array_generic(
      qcheck.int_uniform_inclusive(3, 5),
      qcheck.int_uniform_inclusive(1, 3),
    )
  let #(tree, _seed) = qcheck.generate_tree(generator, qcheck.seed(11))

  tree
  |> tree.to_string(string.inspect)
  |> birdie.snap("bit_array_shrinking__test")
}

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_with_size_from__shrinks_are_the_correct_size__test() -> Nil {
  use #(bit_size, seed) <- qcheck.given(qcheck.tuple2(
    // Do NOT raise the size up.  With large sizes, you can get test timeouts
    // because collecting a giant shrink tree is expensive.
    qcheck.int_uniform_inclusive(0, 10),
    qcheck.int_uniform(),
  ))

  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.bit_array_with_size_from(
        qcheck.int_uniform_inclusive(200, 202),
        bit_size,
      ),
      qcheck.seed(seed),
    )

  let sizes = tree.collect(tree, bit_array.bit_size)
  use size <- list.all(sizes)
  size == bit_size
}

// MARK: Bit arrays (UTF-8)

pub fn bit_array_utf8__generates_valid_utf8_bit_arrays__test() {
  use utf8_bytes <- qcheck.given(qcheck.bit_array_utf8())
  bit_array.is_utf8(utf8_bytes)
}

pub fn bit_array_utf8__is_byte_aligned__test() {
  use utf8_bytes <- qcheck.given(qcheck.bit_array_utf8())

  let bit_size = bit_array.bit_size(utf8_bytes)
  let byte_size = bit_array.byte_size(utf8_bytes)

  // Could do the % 8, but this also tests a property of bit_array module itself
  // for free.
  bit_size == 0 || bit_size == byte_size * 8
}

pub fn bit_array_utf8_non_empty__generates_valid_non_empty_utf8_bit_arrays__test() {
  use utf8_bytes <- qcheck.given(qcheck.bit_array_utf8_non_empty())
  bit_array.is_utf8(utf8_bytes) && bit_array.bit_size(utf8_bytes) >= 8
}

pub fn bit_array_utf8_with_size__generates_valid_utf8_bit_arrays_with_given_num_codepoints__test() {
  let generator = {
    // TODO: this is where the "sized_from" comes in nicely.
    use num_codepoints <- qcheck.bind(qcheck.int_small_positive_or_zero())
    use bit_array <- qcheck.map(qcheck.bit_array_utf8_with_size(num_codepoints))
    #(bit_array, num_codepoints)
  }
  use #(utf8_bytes, expected_num_codepoints) <- qcheck.given(generator)

  let is_valid_utf8 = bit_array.is_utf8(utf8_bytes)

  let codepoints = utf8_bytes_to_codepoints(utf8_bytes)

  let correct_num_codepoints =
    list.length(codepoints) == expected_num_codepoints

  is_valid_utf8 && correct_num_codepoints
}

pub fn bit_array_utf8_with_size_from__generates_valid_utf8_bit_arrays_with_correct_num_codepoints__test() {
  let utf_codepoint = fn(n) {
    let assert Ok(cp) = string.utf_codepoint(n)
    cp
  }
  let generator = {
    use num_codepoints <- qcheck.bind(qcheck.int_small_positive_or_zero())
    use bit_array <- qcheck.map(qcheck.bit_array_utf8_with_size_from(
      qcheck.map(qcheck.int_uniform_inclusive(0, 255), utf_codepoint),
      num_codepoints,
    ))
    #(bit_array, num_codepoints)
  }
  use #(utf8_bytes, expected_num_codepoints) <- qcheck.given(generator)

  let is_valid_utf8 = bit_array.is_utf8(utf8_bytes)

  let codepoints = utf8_bytes_to_codepoints(utf8_bytes)

  let correct_num_codepoints =
    list.length(codepoints) == expected_num_codepoints

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
  let generator = {
    use byte_size <- qcheck.bind(qcheck.int_small_positive_or_zero())
    use bit_array <- qcheck.map(qcheck.bit_array_byte_aligned_with_size_from(
      qcheck.int_uniform_inclusive(0, 10),
      byte_size,
    ))
    #(bit_array, byte_size)
  }
  use #(bit_array, expected_byte_size) <- qcheck.given(generator)
  bit_array.byte_size(bit_array) == expected_byte_size
}

pub fn bit_array_byte_aligned_with_size__makes_arrays_of_correct_size__test() {
  let generator = {
    use byte_size <- qcheck.bind(qcheck.int_small_positive_or_zero())
    use bytes <- qcheck.map(qcheck.bit_array_byte_aligned_with_size(byte_size))
    #(bytes, byte_size)
  }
  use #(bytes, expected_byte_size) <- qcheck.given(generator)
  bit_array.byte_size(bytes) == expected_byte_size
}

pub fn bit_array_byte_aligned_generic__test() {
  use bytes <- qcheck.given(qcheck.bit_array_byte_aligned_generic(
    value_generator: qcheck.int_uniform_inclusive(0, 255),
    byte_size_generator: qcheck.int_uniform_inclusive(0, 8),
  ))
  bit_array.byte_size(bytes) <= 8
}

// MARK: Negative sizes

@external(javascript, "../qcheck_ffi.mjs", "do_nothing")
pub fn bit_array_with_size_from__negative_sizes_yield_empty_bit_arrays__test() -> Nil {
  use bits <- qcheck.given({
    use bit_size <- qcheck.bind(negative_numbers())
    qcheck.bit_array_with_size_from(
      qcheck.int_uniform_inclusive(0, 255),
      bit_size,
    )
  })

  bit_array.bit_size(bits) == 0
}

pub fn bit_array_byte_aligned_with_size_from__negative_sizes_yield_empty_bit_arrays__test() {
  use bytes <- qcheck.given({
    use byte_size <- qcheck.bind(negative_numbers())
    qcheck.bit_array_byte_aligned_with_size_from(
      qcheck.int_uniform_inclusive(0, 255),
      byte_size,
    )
  })

  bit_array.bit_size(bytes) == 0
}

pub fn bit_array_utf8_with_size_from__negative_sizes_yield_empty_bit_arrays__test() {
  use bytes <- qcheck.given({
    use num_codepoints <- qcheck.bind(negative_numbers())
    qcheck.bit_array_utf8_with_size_from(qcheck.utf_codepoint(), num_codepoints)
  })

  bit_array.bit_size(bytes) == 0
}

// Previous versions would crash if the size was too big.
pub fn bit_array_with_size__doesnt_crash_for_huge_numbers__test() {
  use _ <- qcheck.run(
    qcheck.default_config() |> qcheck.with_test_count(10),
    qcheck.bit_array_with_size(1024),
  )
  True
}

// MARK: Sized 

pub fn sizing_bit_arrays__test() -> Nil {
  use bytes <- qcheck.given({
    qcheck.bit_array_byte_aligned_with_size
    |> qcheck.sized_from(qcheck.int_uniform_inclusive(0, 10))
  })

  let byte_size = bit_array.byte_size(bytes)

  0 <= byte_size && byte_size <= 10
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
