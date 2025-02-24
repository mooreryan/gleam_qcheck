import birdie
import gleam/dict
import gleam/int
import gleam/list
import qcheck
import qcheck/tree

pub fn generic_dict__generates_valid_values__test() {
  qcheck.run(
    config: qcheck.default_config(),
    generator: qcheck.generic_dict(
      qcheck.bounded_int(0, 2),
      qcheck.bounded_int(10, 12),
      qcheck.bounded_int(0, 5),
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

fn int_int_dict_to_string(dict: dict.Dict(Int, Int)) -> String {
  dict
  |> dict.to_list
  // Manually sort because the internal "sorting" is not stable across Erlang
  // and JavaScript.
  |> list.sort(fn(kv1, kv2) {
    let #(key1, _) = kv1
    let #(key2, _) = kv2

    int.compare(key1, key2)
  })
  |> list.fold(string_tree.from_string("{ "), fn(acc, kv) {
    let #(k, v) = kv
    string_tree.append(
      acc,
      int.to_string(k) <> " => " <> int.to_string(v) <> ", ",
    )
  })
  |> string_tree.append(" }")
  |> string_tree.to_string()
}

pub fn dict_generators_shrink_on_size_then_on_elements__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.generic_dict(
        keys_from: qcheck.bounded_int(0, 2),
        values_from: qcheck.bounded_int(10, 12),
        size_from: qcheck.bounded_int(0, 3),
      ),
      qcheck.seed(12),
    )

  tree
  |> tree.to_string(int_int_dict_to_string)
  |> birdie.snap("dict_generators_shrink_on_size_then_on_elements__test")
}

pub fn generic_dict__allows_empty_dict__test() {
  use _ <- qcheck.given(qcheck.generic_dict(
    qcheck.bounded_int(0, 2),
    qcheck.bounded_int(10, 12),
    qcheck.constant(0),
  ))
  True
}
