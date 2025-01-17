import domino
import gleam/int
import gleam/option
import gleam/result
import gleam/string
import gleeunit
import gleeunit/should
import lustre/element
import qcheck
import qcheck_viewer as qv

pub fn main() {
  gleeunit.main()
}

// MARK: view error messages

pub fn view_shows_error_if_it_is_in_model_test() {
  let error_message = "yo!!!"

  let model =
    qv.Model(..qv.default_model(), error_message: option.Some(error_message))

  qv.view(model)
  |> domino_from_element
  |> domino.select("#" <> qv.id_error_message)
  |> domino.text
  |> string.contains(error_message)
  |> should.be_true
}

pub fn view_doesnt_show_error_if_it_is_not_in_model_test() {
  let model = qv.Model(..qv.default_model(), error_message: option.None)

  qv.view(model)
  |> domino_from_element
  |> domino.select("#" <> qv.id_error_message)
  |> domino.length
  |> should.equal(0)
}

// MARK: view function options

pub fn int_range_high_is_shown_for_correct_functions_test() {
  use function <- qcheck.given(qcheck_function_generator())
  let model = qv.Model(..qv.default_model(), function:)
  let input =
    qv.view(model)
    |> domino_from_element
    |> domino.select("input[name='range-high']")

  case model.function {
    qv.IntUniformInclusive | qv.FloatUniformInclusive ->
      domino.length(input) == 1
    _ -> domino.length(input) == 0
  }
}

pub fn int_range_low_is_shown_for_correct_functions_test() {
  use function <- qcheck.given(qcheck_function_generator())
  let model = qv.Model(..qv.default_model(), function:)
  let input =
    qv.view(model)
    |> domino_from_element
    |> domino.select("input[name='range-low']")

  case model.function {
    qv.IntUniformInclusive | qv.FloatUniformInclusive ->
      domino.length(input) == 1
    _ -> domino.length(input) == 0
  }
}

// MARK: update

pub fn user_changed_function_test() {
  use function <- qcheck.given(qcheck_function_generator())
  let model = qv.Model(..qv.default_model(), function:)
  let msg = qv.UserChangedFunction(qv.qcheck_function_to_string(function))
  let #(model, _) = qv.update(model, msg)
  model.function == function && model.error_message == option.None
}

// MARK: parsing ints

// Parsing ints: min and max values

pub fn parse_int_range_high__val_is_gte_int_min__test() {
  let assert qv.UserUpdatedIntRangeHigh(result) =
    { qv.min_int - 1 }
    |> int.to_string
    |> qv.parse_int_range_high(low: qv.min_int - 2)

  result |> should.be_error
}

pub fn parse_int_range_low__val_is_gte_int_min__test() {
  let assert qv.UserUpdatedIntRangeLow(result) =
    { qv.min_int - 1 }
    |> int.to_string
    |> qv.parse_int_range_low(high: qv.min_int)

  result |> should.be_error
}

pub fn parse_int_range_high__val_is_lte_int_max__test() {
  let assert qv.UserUpdatedIntRangeHigh(result) =
    { qv.max_int + 1 }
    |> int.to_string
    |> qv.parse_int_range_high(low: qv.max_int)

  result |> should.be_error
}

pub fn parse_int_range_low__val_is_lte_int_max__test() {
  let assert qv.UserUpdatedIntRangeLow(result) =
    { qv.max_int + 1 }
    |> int.to_string
    |> qv.parse_int_range_low(high: qv.max_int + 2)

  result |> should.be_error
}

// Parsing ints: good values

pub fn parse_int_range_high__good_values__test() {
  use #(low, high) <- qcheck.given(good_high_low_values_generator())

  let assert qv.UserUpdatedIntRangeHigh(Ok(result)) =
    qv.parse_int_range_high(int.to_string(high), low:)

  result == high
}

pub fn parse_int_range_low__good_values__test() {
  use #(low, high) <- qcheck.given(good_high_low_values_generator())

  let assert qv.UserUpdatedIntRangeLow(Ok(result)) =
    qv.parse_int_range_low(int.to_string(low), high: high)

  result == low
}

fn good_high_low_values_generator() {
  use low <- qcheck.bind(qcheck.int_uniform_inclusive(
    qv.min_int,
    qv.max_int - 1,
  ))
  use high <- qcheck.map(qcheck.int_uniform_inclusive(low, qv.max_int))
  let assert True = qv.min_int <= low && low < high && high <= qv.max_int
  #(low, high)
}

// Parsing ints: Low-high ordering

pub fn parse_int_range_high__high_must_be_gt_low__test() {
  use #(low, high) <- qcheck.given(high_lt_low_generator())

  let assert qv.UserUpdatedIntRangeHigh(result) =
    qv.parse_int_range_high(int.to_string(high), low:)

  result.is_error(result)
}

pub fn parse_int_range_low__high_must_be_gt_low__test() {
  use #(low, high) <- qcheck.given(high_lt_low_generator())

  let assert qv.UserUpdatedIntRangeLow(result) =
    qv.parse_int_range_low(int.to_string(low), high:)

  result.is_error(result)
}

fn high_lt_low_generator() {
  use low <- qcheck.bind(qcheck.int_uniform_inclusive(
    qv.min_int + 1,
    qv.max_int,
  ))
  use high <- qcheck.map(qcheck.int_uniform_inclusive(qv.min_int, low))
  let assert True = high < low
  #(low, high)
}

// Parsing non-integers

pub fn parse_int_range_high__high_must_be_an_int__test() {
  use high <- qcheck.given(non_digit_char_generator())

  let assert qv.UserUpdatedIntRangeHigh(result) =
    qv.parse_int_range_high(high, low: qv.min_int)

  result.is_error(result)
}

pub fn parse_int_range_low__low_must_be_an_int__test() {
  use low <- qcheck.given(non_digit_char_generator())

  let assert qv.UserUpdatedIntRangeLow(result) =
    qv.parse_int_range_low(low, high: qv.max_int)

  result.is_error(result)
}

fn non_digit_char_generator() {
  use char <- qcheck.map(qcheck.char())
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> "a"
    char -> char
  }
}

// MARK: Type generators

fn qcheck_function_generator() {
  qcheck.from_generators([
    qcheck.return(qv.IntUniform),
    qcheck.return(qv.IntUniformInclusive),
    qcheck.return(qv.IntSmallPositiveOrZero),
    qcheck.return(qv.IntSmallStrictlyPositive),
    qcheck.return(qv.Float),
    qcheck.return(qv.FloatUniformInclusive),
    qcheck.return(qv.Char),
    qcheck.return(qv.CharUniform),
    qcheck.return(qv.CharUniformInclusive),
    qcheck.return(qv.CharUtfCodepoint),
    qcheck.return(qv.CharUppercase),
    qcheck.return(qv.CharLowercase),
    qcheck.return(qv.CharDigit),
    qcheck.return(qv.CharPrintUniform),
    qcheck.return(qv.CharAlpha),
    qcheck.return(qv.CharAlphaNumeric),
    qcheck.return(qv.CharWhitespace),
    qcheck.return(qv.CharPrint),
  ])
}

// MARK: domino utils

fn domino_from_element(element) {
  element |> element.to_string |> domino.from_string
}
