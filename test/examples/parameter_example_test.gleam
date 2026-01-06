import gleeunit/should
import qcheck

type Box {
  Box(x: Int, y: Int, w: Int, h: Int)
}

fn box_generator() {
  qcheck.return({
    use x <- qcheck.parameter
    use y <- qcheck.parameter
    use w <- qcheck.parameter
    use h <- qcheck.parameter
    Box(x:, y:, w:, h:)
  })
  |> qcheck.apply(qcheck.bounded_int(-100, 100))
  |> qcheck.apply(qcheck.bounded_int(-100, 100))
  |> qcheck.apply(qcheck.bounded_int(1, 100))
  |> qcheck.apply(qcheck.bounded_int(1, 100))
}

pub fn parameter_example__test() {
  use _box <- qcheck.given(box_generator())

  // Test some interesting property of boxes here.

  // (This `True` is a standin for your property.)
  should.be_true(True)
}

// Another approach using applicative style.

fn x_gen() {
  qcheck.bounded_int(-100, 100)
}

fn y_gen() {
  qcheck.bounded_int(-100, 100)
}

fn w_gen() {
  qcheck.bounded_int(1, 100)
}

fn h_gen() {
  qcheck.bounded_int(1, 100)
}

fn box_generator_with_map4() {
  use x, y, w, h <- qcheck.map4(x_gen(), y_gen(), w_gen(), h_gen())
  Box(x:, y:, w:, h:)
}

// Something like this could make it easier to handle changes to the Box definition.
// See https://github.com/mooreryan/gleam_qcheck/issues/13
fn box_generator_with_fun_call_style() {
  let box =
    qcheck.return(fn(x) { fn(y) { fn(w) { fn(h) { Box(x:, y:, w:, h:) } } } })

  let x = qcheck.apply(_, x_gen())
  let y = qcheck.apply(_, y_gen())
  let w = qcheck.apply(_, w_gen())
  let h = qcheck.apply(_, h_gen())

  box |> x |> y |> w |> h
}

// These two tests are here to avoid the unused function warning.

pub fn parameter_example_2__test() {
  use _box <- qcheck.given(box_generator_with_map4())

  // Test some interesting property of boxes here.

  // (This `True` is a standin for your property.)
  should.be_true(True)
}

pub fn parameter_example_3__test() {
  use _box <- qcheck.given(box_generator_with_fun_call_style())

  // Test some interesting property of boxes here.

  // (This `True` is a standin for your property.)
  should.be_true(True)
}
