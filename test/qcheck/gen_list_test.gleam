import birdie
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder
import qcheck
import qcheck/tree
import qcheck_gleeunit_utils/test_spec

pub fn generic_list__generates_valid_values__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.generic_list(
      elements_from: qcheck.bounded_int(-5, 5),
      length_from: qcheck.bounded_int(2, 5),
    ),
    property: fn(l) {
      let len = list.length(l)
      2 <= len && len <= 5 && list.all(l, fn(n) { -5 <= n && n <= 5 })
    },
  )
}

pub fn list_from__generates_valid_values__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.list_from(qcheck.bounded_int(-1000, 1000)),
    property: fn(l) { list.all(l, fn(n) { -1000 <= n && n <= 1000 }) },
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
      qcheck.generic_list(
        elements_from: qcheck.bounded_int(-1, 2),
        length_from: qcheck.bounded_int(0, 3),
      ),
      qcheck.seed(10_003),
    )

  tree
  |> tree.to_string(int_list_to_string)
  |> birdie.snap("list_generators_shrink_on_size_then_on_elements__test")
}

pub fn generic_list_doesnt_shrink_out_of_length_range__test_() {
  use <- test_spec.make_with_timeout(60)
  let min_length = 2
  let max_length = 4

  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.generic_list(
        elements_from: qcheck.bounded_int(1, 2),
        length_from: qcheck.bounded_int(min_length, max_length),
      ),
      qcheck.random_seed(),
    )

  all_lengths_good(tree, min_length:, max_length:)
}

pub fn fixed_length_list_from__generates_correct_length__test() {
  use #(list, expected_length) <- qcheck.given({
    use length <- qcheck.bind(qcheck.small_non_negative_int())
    use list <- qcheck.map(qcheck.fixed_length_list_from(
      qcheck.small_non_negative_int(),
      length,
    ))
    #(list, length)
  })

  list.length(list) == expected_length
}

fn all_lengths_good(tree, min_length min_length, max_length max_length) {
  let tree.Tree(root, children) = tree

  let root_length = list.length(root)
  let assert True = min_length <= root_length && root_length <= max_length

  children
  |> yielder.each(fn(tree) { all_lengths_good(tree, min_length, max_length) })
}
