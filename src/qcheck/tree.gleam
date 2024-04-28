//// This module provides a tree data structure used to represent a 
//// pseudo-randomly generated value an its shrunk values.  This "integrated
//// shrinking" is convenient as most generators get shrinking "for free" that 
//// that shrinking does not break invaraints. 

import gleam/function
import gleam/iterator.{type Iterator}
import gleam/option.{type Option, None, Some}
import qcheck/utils

pub type Tree(a) {
  Tree(a, Iterator(Tree(a)))
}

// `shrink` should probably be `shrink_steps` or `make_shrink_steps`
pub fn make_primitive(root x: a, shrink shrink: fn(a) -> Iterator(a)) -> Tree(a) {
  let shrink_trees =
    shrink(x)
    |> iterator.map(make_primitive(_, shrink))

  Tree(x, shrink_trees)
}

pub fn map(tree: Tree(a), f: fn(a) -> b) -> Tree(b) {
  let Tree(x, xs) = tree
  let y = f(x)
  let ys = iterator.map(xs, fn(smaller_x) { map(smaller_x, f) })

  Tree(y, ys)
}

pub fn bind(tree: Tree(a), f: fn(a) -> Tree(b)) -> Tree(b) {
  let Tree(x, xs) = tree

  let Tree(y, ys_of_x) = f(x)

  let ys_of_xs = iterator.map(xs, fn(smaller_x) { bind(smaller_x, f) })

  let ys = iterator.append(ys_of_xs, ys_of_x)

  Tree(y, ys)
}

pub fn apply(f: Tree(fn(a) -> b), x: Tree(a)) -> Tree(b) {
  let Tree(x0, xs) = x
  let Tree(f0, fs) = f

  let y = f0(x0)

  let ys =
    iterator.append(
      iterator.map(fs, fn(f_) { apply(f_, x) }),
      iterator.map(xs, fn(x_) { apply(f, x_) }),
    )

  Tree(y, ys)
}

pub fn return(x: a) -> Tree(a) {
  Tree(x, iterator.empty())
}

pub fn map2(f: fn(a, b) -> c, a: Tree(a), b: Tree(b)) -> Tree(c) {
  f
  |> function.curry2
  |> return
  |> apply(a)
  |> apply(b)
}

pub fn iterator_list(l: List(Tree(a))) -> Tree(List(a)) {
  case l {
    [] -> return([])
    [hd, ..tl] -> {
      map2(utils.list_cons, hd, iterator_list(tl))
    }
  }
}

fn iterator_cons(element: a, iterator: fn() -> Iterator(a)) -> Iterator(a) {
  iterator.yield(element, iterator)
}

pub fn option(tree: Tree(a)) -> Tree(Option(a)) {
  let Tree(x, xs) = tree

  // Shrink trees will all have None as a value.
  let shrinks = iterator_cons(return(None), fn() { iterator.map(xs, option) })

  Tree(Some(x), shrinks)
}

// Debugging trees

import gleam/string

pub fn to_string(tree: Tree(a), a_to_string: fn(a) -> String) -> String {
  do_to_string(tree, a_to_string, level: 0, max_level: 99_999_999, acc: [])
}

pub fn to_string_(
  tree: Tree(a),
  a_to_string: fn(a) -> String,
  max_depth max_depth: Int,
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
          |> iterator.map(fn(tree) {
            do_to_string(tree, a_to_string, level + 1, max_level, acc)
          })
          |> iterator.to_list
          |> string.join("")

        True ->
          children
          |> iterator.map(fn(_) { "" })
          |> iterator.to_list
          |> string.join("")
      }

      let root = padding <> a_to_string(root)

      root <> "\n" <> children
    }
  }
}
