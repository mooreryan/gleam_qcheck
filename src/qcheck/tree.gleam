//// Trees
////
//// This module contains functions for creating and manipulating shrink trees.
////
//// They are mostly inteded for internal use or "advanced" manual construction
//// of generators.  In typical usage, you will probably not need to interact
//// with these functions much, if at all.  As such, they are currently mostly
//// undocumented.
////
//// In fact, if you are using these functions a lot, file a issue on GitHub
//// and let me know if there are any generator combinators that you're missing.
////
//// There are functions for dealing with the [Tree](#Tree) type directly, but
//// they are low-level and you should not need to use them much.
////
//// - The [Tree](#Tree) type
//// - [new](#new)
//// - [return](#return)
//// - [map](#map)
//// - [map2](#map2)
//// - [bind](#bind)
//// - [apply](#apply)
//// - [collect](#collect)
//// - [sequence_trees](#sequence_trees)
//// - [option](#option)
//// - [to_string](#to_string)
//// - [to_string_with_max_depth](#to_string_with_max_depth)
////

import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/yielder.{type Yielder}

pub type Tree(a) {
  Tree(a, Yielder(Tree(a)))
}

// `shrink` should probably be `shrink_steps` or `make_shrink_steps`
pub fn new(x: a, shrink: fn(a) -> Yielder(a)) -> Tree(a) {
  let shrink_trees =
    shrink(x)
    |> yielder.map(new(_, shrink))

  Tree(x, shrink_trees)
}

pub fn map(tree: Tree(a), f: fn(a) -> b) -> Tree(b) {
  let Tree(x, xs) = tree
  let y = f(x)
  let ys = yielder.map(xs, fn(smaller_x) { map(smaller_x, f) })

  Tree(y, ys)
}

pub fn bind(tree: Tree(a), f: fn(a) -> Tree(b)) -> Tree(b) {
  let Tree(x, xs) = tree

  let Tree(y, ys_of_x) = f(x)

  let ys_of_xs = yielder.map(xs, fn(smaller_x) { bind(smaller_x, f) })

  let ys = yielder.append(ys_of_xs, ys_of_x)

  Tree(y, ys)
}

pub fn apply(f: Tree(fn(a) -> b), x: Tree(a)) -> Tree(b) {
  let Tree(x0, xs) = x
  let Tree(f0, fs) = f

  let y = f0(x0)

  let ys =
    yielder.append(
      yielder.map(fs, fn(f_) { apply(f_, x) }),
      yielder.map(xs, fn(x_) { apply(f, x_) }),
    )

  Tree(y, ys)
}

pub fn return(x: a) -> Tree(a) {
  Tree(x, yielder.empty())
}

pub fn map2(a: Tree(a), b: Tree(b), f: fn(a, b) -> c) -> Tree(c) {
  {
    use x1 <- parameter
    use x2 <- parameter
    f(x1, x2)
  }
  |> return
  |> apply(a)
  |> apply(b)
}

/// `sequence_trees(list_of_trees)` sequences a list of trees into a tree of lists.
///
pub fn sequence_trees(l: List(Tree(a))) -> Tree(List(a)) {
  case l {
    [] -> return([])
    [hd, ..tl] -> {
      map2(hd, sequence_trees(tl), list_cons)
    }
  }
}

fn yielder_cons(element: a, yielder: fn() -> Yielder(a)) -> Yielder(a) {
  yielder.yield(element, yielder)
}

pub fn option(tree: Tree(a)) -> Tree(Option(a)) {
  let Tree(x, xs) = tree

  // Shrink trees will all have None as a value.
  let shrinks = yielder_cons(return(None), fn() { yielder.map(xs, option) })

  Tree(Some(x), shrinks)
}

// Debugging trees

/// Collect values of the tree into a list, while processing them with the
/// mapping given function `f`.
///
pub fn collect(tree: Tree(a), f: fn(a) -> b) -> List(b) {
  do_collect(tree, f, [])
}

fn do_collect(tree: Tree(a), f: fn(a) -> b, acc: List(b)) -> List(b) {
  let Tree(root, children) = tree

  let acc =
    yielder.fold(children, acc, fn(a_list, a_tree) {
      do_collect(a_tree, f, a_list)
    })

  [f(root), ..acc]
}

/// `to_string(tree, element_to_string)` converts a tree into an unspecified string representation.
///
/// - `element_to_string`: a function that converts individual elements of the tree to strings.
///
pub fn to_string(tree: Tree(a), a_to_string: fn(a) -> String) -> String {
  do_to_string(tree, a_to_string, level: 0, max_level: 99_999_999, acc: [])
}

/// Like `to_string` but with a configurable `max_depth`.
///
pub fn to_string_max_depth(
  tree: Tree(a),
  a_to_string: fn(a) -> String,
  max_depth: Int,
) -> String {
  do_to_string(tree, a_to_string, level: 0, max_level: max_depth, acc: [])
}

fn do_to_string(
  tree: Tree(a),
  a_to_string a_to_string: fn(a) -> String,
  level level: Int,
  max_level max_level: Int,
  acc acc: List(String),
) -> String {
  case tree {
    Tree(root, children) -> {
      let padding = string.repeat("-", times: level)

      let children = case level > max_level {
        False ->
          children
          |> yielder.map(fn(tree) {
            do_to_string(tree, a_to_string, level + 1, max_level, acc)
          })
          |> yielder.to_list
          |> string.join("")

        True ->
          children
          |> yielder.map(fn(_) { "" })
          |> yielder.to_list
          |> string.join("")
      }

      let root = padding <> a_to_string(root)

      root <> "\n" <> children
    }
  }
}

fn parameter(f: fn(x) -> y) -> fn(x) -> y {
  f
}

fn list_cons(x, xs) {
  [x, ..xs]
}
