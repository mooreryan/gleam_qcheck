import birdie
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import gleeunit/should
import qcheck
import qcheck/tree

pub fn generic_set__generates_valid_values__test() {
  use s <- qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.generic_set(
      elements_from: qcheck.bounded_int(-5, 5),
      size_from: qcheck.bounded_int(0, 5),
    ),
  )
  let len = set.size(s)
  let correct_elements =
    set.to_list(s)
    |> list.all(fn(n) { -5 <= n && n <= 5 })
  should.be_true(len <= 5 && correct_elements)
}

fn int_set_to_string(s) {
  "["
  <> {
    set.to_list(s)
    // Manually sort because the internal "sorting" is not stable across Erlang
    // and JavaScript.
    |> list.sort(int.compare)
    |> list.map(int.to_string)
    |> string.join(",")
  }
  <> "]"
}

// Note: the shrinks don't look quite as you would expect compared to the list
// test because sets cannot have duplicates as the lists can.
pub fn set_generators_shrink_on_size_then_on_elements__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.generic_set(
        elements_from: qcheck.bounded_int(-1, 2),
        size_from: qcheck.bounded_int(0, 3),
      ),
      qcheck.seed(10_003),
    )

  tree
  |> tree.to_string(int_set_to_string)
  |> birdie.snap("set_generators_shrink_on_size_then_on_elements__test")
}
