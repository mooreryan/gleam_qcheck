import gleam/iterator.{type Iterator}
import gleam/option.{type Option, None, Some}

pub type Tree(a) {
  Tree(a, Iterator(Tree(a)))
}

pub fn make_primative(shrink shrink: fn(a) -> Iterator(a), root x: a) -> Tree(a) {
  let shrink_trees =
    shrink(x)
    |> iterator.map(make_primative(shrink, _))

  Tree(x, shrink_trees)
}

pub fn map(tree: Tree(a), f: fn(a) -> b) -> Tree(b) {
  let Tree(x, xs) = tree
  let y = f(x)
  let ys = iterator.map(xs, fn(smaller_x) { map(smaller_x, f) })

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
  // TODO: should put at beginning or end?
  let shrinks = iterator_cons(return(None), fn() { iterator.map(xs, option) })

  Tree(Some(x), shrinks)
}
