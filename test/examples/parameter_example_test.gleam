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
  True
}
