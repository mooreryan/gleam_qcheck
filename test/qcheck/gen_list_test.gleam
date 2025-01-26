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
      element_generator: qcheck.int_uniform_inclusive(-5, 5),
      length_generator: qcheck.int_uniform_inclusive(2, 5),
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
        element_generator: qcheck.int_uniform_inclusive(-1, 2),
        length_generator: qcheck.int_uniform_inclusive(0, 3),
      ),
      qcheck.seed(10_003),
    )

  tree
  |> qcheck.tree_to_string(int_list_to_string)
  |> birdie.snap("list_generators_shrink_on_size_then_on_elements__test")
}

pub fn list_generic_doesnt_shrink_out_of_length_range__test_() {
  use <- test_spec.make_with_timeout(60)
  let min_length = 2
  let max_length = 4

  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.list_generic(
        element_generator: qcheck.int_uniform_inclusive(1, 2),
        length_generator: qcheck.int_uniform_inclusive(min_length, max_length),
      ),
      qcheck.seed_random(),
    )

  all_lengths_good(tree, min_length:, max_length:)
}

pub fn list_with_length_from__generates_correct_length__test() {
  use #(list, expected_length) <- qcheck.given({
    use length <- qcheck.bind(qcheck.int_small_positive_or_zero())
    use list <- qcheck.map(qcheck.list_with_length_from(
      qcheck.int_small_positive_or_zero(),
      length,
    ))
    #(list, length)
  })

  list.length(list) == expected_length
}

fn all_lengths_good(tree, min_length min_length, max_length max_length) {
  let qcheck.Tree(root, children) = tree

  let root_length = list.length(root)
  let assert True = min_length <= root_length && root_length <= max_length

  children
  |> yielder.each(fn(tree) { all_lengths_good(tree, min_length, max_length) })
}
