import birdie
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder
import qcheck
import qcheck_gleeunit_utils/test_spec

pub fn list_generic__generates_valid_values__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.list_generic(
      qcheck.int_uniform_inclusive(-5, 5),
      min_length: 2,
      max_length: 5,
    ),
    property: fn(l) {
      let len = list.length(l)
      2 <= len && len <= 5 && list.all(l, fn(n) { -5 <= n && n <= 5 })
    },
  )
}

fn int_list_to_string(l) {
  "["
  <> {
    list.map(l, int.to_string)
    |> string.join(",")
  }
  <> "]"
}

pub fn list_generators_shrink_on_size_then_on_elements__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.list_generic(
        qcheck.int_uniform_inclusive(-1, 2),
        min_length: 0,
        max_length: 3,
      ),
      qcheck.seed(10_003),
    )

  tree
  |> qcheck.tree_to_string(int_list_to_string)
  |> birdie.snap("list_generators_shrink_on_size_then_on_elements__test")
}

pub fn list_generic_doesnt_shkrink_out_of_length_range__test_() {
  use <- test_spec.make_with_timeout(60)
  let min_length = 2
  let max_length = 4

  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.list_generic(
        qcheck.int_uniform_inclusive(1, 2),
        min_length:,
        max_length:,
      ),
      qcheck.seed_random(),
    )

  all_lengths_good(tree, min_length:, max_length:)
}

fn all_lengths_good(tree, min_length min_length, max_length max_length) {
  let qcheck.Tree(root, children) = tree

  let root_length = list.length(root)
  let assert True = min_length <= root_length && root_length <= max_length

  children
  |> yielder.each(fn(tree) { all_lengths_good(tree, min_length, max_length) })
}
