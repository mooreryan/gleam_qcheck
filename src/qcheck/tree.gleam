import gleam/iterator.{type Iterator}
import gleam/option.{type Option, None, Some}

pub type Tree(a) {
  Tree(a, Iterator(Tree(a)))
}

// `shrink` should probably be `shrink_steps` or `make_shrink_steps`
pub fn make_primative(root x: a, shrink shrink: fn(a) -> Iterator(a)) -> Tree(a) {
  let shrink_trees =
    shrink(x)
    |> iterator.map(make_primative(_, shrink))

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

pub fn return(x: a) -> Tree(a) {
  Tree(x, iterator.empty())
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
  do_to_string(tree, a_to_string, level: 0, acc: [])
}

fn do_to_string(
  tree: Tree(a),
  a_to_string a_to_string: fn(a) -> String,
  level level: Int,
  acc acc: List(String),
) -> String {
  case tree {
    Tree(root, children) -> {
      let padding = string.repeat("-", times: level)

      let children =
        children
        |> iterator.map(fn(tree) {
          do_to_string(tree, a_to_string, level + 1, acc)
        })
        |> iterator.to_list
        |> string.join("")

      let root = padding <> a_to_string(root)

      root <> "\n" <> children
    }
  }
}
