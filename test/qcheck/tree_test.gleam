import birdie
import gleam/int
import gleam/iterator
import gleam/option.{None, Some}
import gleeunit/should
import qcheck.{type Tree, Tree}

fn identity(x) {
  x
}

pub fn int_tree_root_8_shrink_towards_zero__test() {
  qcheck.make_primitive_tree(8, qcheck.shrink_int_towards_zero())
  |> qcheck.tree_to_string(int.to_string)
  |> birdie.snap("int_tree_root_8_shrink_towards_zero__test")
}

pub fn int_tree_root_2_shrink_towards_6__test() {
  qcheck.make_primitive_tree(2, qcheck.shrink_int_towards(6))
  |> qcheck.tree_to_string(int.to_string)
  |> birdie.snap("int_tree_root_2_shrink_towards_6__test")
}

pub fn int_tree_atomic_shrinker__test() {
  qcheck.make_primitive_tree(10, qcheck.shrink_atomic())
  |> qcheck.tree_to_string(int.to_string)
  |> should.equal("10\n")
}

pub fn int_option_tree__test() {
  qcheck.make_primitive_tree(4, qcheck.shrink_int_towards_zero())
  |> qcheck.option_tree()
  |> qcheck.tree_to_string(fn(n) {
    case n {
      None -> "N"
      Some(n) -> int.to_string(n)
    }
  })
  |> birdie.snap("int_option_tree__test")
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

pub fn custom_type_tree__test() {
  qcheck.make_primitive_tree(4, qcheck.shrink_int_towards_zero())
  |> qcheck.map_tree(fn(n) {
    case n % 2 == 0 {
      True -> First(n)
      False -> Second(n)
    }
  })
  |> qcheck.tree_to_string(fn(either) {
    either
    |> either_to_string(int.to_string, int.to_string)
  })
  |> birdie.snap("custom_type_tree__test")
}

pub fn trivial_map_test() {
  do_trivial_map_test(5)
}

fn do_trivial_map_test(i) {
  case i <= 0 {
    True -> Nil
    False -> {
      let a =
        qcheck.make_primitive_tree(i, qcheck.shrink_int_towards_zero())
        |> qcheck.tree_to_string(int.to_string)

      let b =
        qcheck.make_primitive_tree(i, qcheck.shrink_int_towards_zero())
        |> qcheck.map_tree(identity)
        |> qcheck.tree_to_string(int.to_string)

      should.equal(a, b)
    }
  }
}

// bind
//
//

type MyInt {
  MyInt(Int)
}

// You need a custom shrinker here for the bind.
fn my_int_towards_zero() {
  fn(my_int) {
    let MyInt(n) = my_int
    qcheck.shrink_int_towards_zero()(n)
    |> iterator.map(MyInt)
  }
}

fn my_int_to_string(my_int) {
  let MyInt(n) = my_int

  int.to_string(n) <> "*"
}

// Note, these trees will not be the same as the ones generated with the map.
pub fn custom_type_tree_with_bind__test() {
  qcheck.make_primitive_tree(3, qcheck.shrink_int_towards_zero())
  |> qcheck.bind_tree(fn(n) {
    qcheck.make_primitive_tree(MyInt(n), shrink: my_int_towards_zero())
  })
  |> qcheck.tree_to_string(my_int_to_string)
  |> birdie.snap("custom_type_tree_with_bind__test")
}

fn curry2(f) {
  fn(a) { fn(b) { f(a, b) } }
}

fn curry3(f) {
  fn(a) { fn(b) { fn(c) { f(a, b, c) } } }
}

// apply
//
//

pub fn apply__test() {
  let int3_tuple_to_string = fn(abc) {
    let #(a, b, c) = abc
    int.to_string(a) <> ", " <> int.to_string(b) <> ", " <> int.to_string(c)
  }

  let tuple3 =
    fn(a, b, c) { #(a, b, c) }
    |> curry3

  let make_tree = fn(root: a) -> Tree(a) {
    qcheck.make_primitive_tree(root, qcheck.shrink_atomic())
  }

  let result =
    tuple3
    |> qcheck.return_tree
    |> qcheck.apply_tree(make_tree(3))
    |> qcheck.apply_tree(make_tree(33))
    |> qcheck.apply_tree(make_tree(333))

  let expected = make_tree(#(3, 33, 333))

  should.equal(
    qcheck.tree_to_string(result, int3_tuple_to_string),
    qcheck.tree_to_string(expected, int3_tuple_to_string),
  )
}

pub fn apply_with_shrinking__test() {
  let int2_tuple_to_string = fn(abc) {
    let #(a, b) = abc
    "(" <> int.to_string(a) <> ", " <> int.to_string(b) <> ")"
  }

  let tuple2 =
    fn(a, b) { #(a, b) }
    |> curry2

  let make_int_tree = fn(root: Int) -> Tree(Int) {
    qcheck.make_primitive_tree(root, qcheck.shrink_int_towards_zero())
  }

  let result =
    tuple2
    |> qcheck.return_tree
    |> qcheck.apply_tree(make_int_tree(1))
    |> qcheck.apply_tree(make_int_tree(2))

  result
  |> qcheck.tree_to_string(int2_tuple_to_string)
  |> birdie.snap("apply_with_shrinking__test")
}
