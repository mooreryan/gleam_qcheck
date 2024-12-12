import gleam/int
import gleam/option.{Some}
import gleam/regexp.{Match}
import gleam/result
import gleam/string
import qcheck.{type Generator}

type Point {
  Point(Int, Int)
}

fn make_point(x: Int, y: Int) -> Point {
  Point(x, y)
}

fn point_generator() -> Generator(Point) {
  qcheck.map2(make_point, qcheck.int_uniform(), qcheck.int_uniform())
}

fn point_equal(p1: Point, p2: Point) -> Bool {
  let Point(x1, y1) = p1
  let Point(x2, y2) = p2

  x1 == x2 && y1 == y2
}

fn point_to_string(point: Point) -> String {
  let Point(x, y) = point
  "(" <> int.to_string(x) <> " " <> int.to_string(y) <> ")"
}

fn point_of_string(string: String) -> Result(Point, String) {
  use re <- result.try(
    // This is the one that is intentionally broken:
    // regexp.from_string("\\((\\d+) (\\d+)\\)")
    // And this is the one that is fixed to be okay with negative integers.
    regexp.from_string("\\((-?\\d+) (-?\\d+)\\)")
    |> result.map_error(string.inspect),
  )

  use submatches <- result.try(case regexp.scan(re, string) {
    [Match(_content, submatches)] -> Ok(submatches)
    _ -> Error("expected a single match")
  })

  use xy <- result.try(case submatches {
    [Some(x), Some(y)] -> Ok(#(x, y))
    _ -> Error("expected two submatches")
  })

  use xy <- result.try(case int.parse(xy.0), int.parse(xy.1) {
    Ok(x), Ok(y) -> Ok(#(x, y))
    Error(Nil), Ok(_) -> Error("failed to parse x value")
    Ok(_), Error(Nil) -> Error("failed to parse y value")
    Error(Nil), Error(Nil) -> Error("failed to parse x and y values")
  })

  Ok(Point(xy.0, xy.1))
}

pub fn point_serialization_roundtripping__test() {
  use generated_point <- qcheck.given(point_generator())

  let assert Ok(parsed_point) =
    generated_point
    |> point_to_string
    |> point_of_string

  point_equal(generated_point, parsed_point)
}
