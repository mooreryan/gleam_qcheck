import birdie
import gleam/dict
import gleam/int
import gleam/list
import qcheck

pub fn dict_generic__generates_valid_values__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.dict_generic(
      qcheck.int_uniform_inclusive(0, 2),
      qcheck.int_uniform_inclusive(10, 12),
      max_length: 5,
    ),
    property: fn(d) {
      let size_is_good = dict.size(d) <= 5

      let keys_are_good =
        dict.keys(d)
        |> list.all(fn(n) { n == 0 || n == 1 || n == 2 })

      let values_are_good =
        dict.values(d)
        |> list.all(fn(n) { n == 10 || n == 11 || n == 12 })

      size_is_good && keys_are_good && values_are_good
    },
  )
}

import gleam/string_tree

fn int_int_dict_to_string(d: dict.Dict(Int, Int)) -> String {
  dict.fold(d, string_tree.from_string("{ "), fn(sb, k, v) {
    string_tree.append(
      sb,
      int.to_string(k) <> " => " <> int.to_string(v) <> ", ",
    )
  })
  |> string_tree.append(" }")
  |> string_tree.to_string()
}

pub fn dict_generators_shrink_on_size_then_on_elements__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.dict_generic(
        key_generator: qcheck.int_uniform_inclusive(0, 2),
        value_generator: qcheck.int_uniform_inclusive(10, 12),
        max_length: 3,
      ),
      qcheck.seed_new(12),
    )

  tree
  |> qcheck.tree_to_string(int_int_dict_to_string)
  |> birdie.snap("dict_generators_shrink_on_size_then_on_elements__test")
}

pub fn dict_generic__allows_empty_dict__test() {
  use _ <- qcheck.given(qcheck.dict_generic(
    qcheck.int_uniform_inclusive(0, 2),
    qcheck.int_uniform_inclusive(10, 12),
    0,
  ))
  True
}
