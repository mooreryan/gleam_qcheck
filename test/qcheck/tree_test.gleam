import birdie
import gleam/int
import gleam/option.{None, Some}
import gleeunit/should
import qcheck/shrink
import qcheck/tree

pub fn tree_root_8_test() {
  tree.make_primative(8, shrink.int_towards_zero())
  |> tree.to_string(int.to_string)
  |> birdie.snap("tree_root_8_test")
}

pub fn int_tree_atomic_shrinker_test() {
  tree.make_primative(10, shrink.atomic())
  |> tree.to_string(int.to_string)
  |> should.equal("10\n")
}

pub fn int_option_tree_test() {
  tree.make_primative(4, shrink.int_towards_zero())
  |> tree.option()
  |> tree.to_string(fn(n) {
    case n {
      None -> "N"
      Some(n) -> int.to_string(n)
    }
  })
  |> birdie.snap("int_option_tree_test")
}

type Either(a, b) {
  First(a)
  Second(b)
}

fn either_to_string(either: Either(a, b), a_to_string, b_to_string) -> String {
  case either {
    First(a) -> "First(" <> a_to_string(a) <> ")"
    Second(b) -> "Second(" <> b_to_string(b) <> ")"
  }
}

pub fn either_test() {
  tree.make_primative(4, shrink.int_towards_zero())
  |> tree.map(fn(n) {
    case n % 2 == 0 {
      True -> First(n)
      False -> Second(n)
    }
  })
  |> tree.to_string(fn(either) {
    either
    |> either_to_string(int.to_string, int.to_string)
  })
  |> birdie.snap("either_test")
}
