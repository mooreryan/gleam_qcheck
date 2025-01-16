import domino
import gleam/io
import gleam/option
import gleam/string
import gleeunit
import gleeunit/should
import lustre/element
import qcheck_viewer as qv

pub fn main() {
  gleeunit.main()
}

pub fn view_shows_error_if_it_is_in_model_test() {
  let error_message = "yo!!!"

  let model =
    qv.Model(..qv.default_model(), error_message: option.Some(error_message))

  qv.view(model)
  |> element.to_string
  |> domino.from_string
  |> domino.select("#" <> qv.id_error_message)
  |> domino.text
  |> string.contains(error_message)
  |> should.be_true
}

pub fn view_doesnt_show_error_if_it_is_not_in_model_test() {
  let model = qv.Model(..qv.default_model(), error_message: option.None)

  qv.view(model)
  |> element.to_string
  |> domino.from_string
  |> domino.select("#" <> qv.id_error_message)
  |> domino.length
  |> should.equal(0)
}
