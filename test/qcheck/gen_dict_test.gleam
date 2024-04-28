import birdie
import gleam/dict
import gleam/int
import gleam/list
import gleeunit/should
import prng/seed
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/tree

pub fn dict_generic__generates_valid_values__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.dict_generic(
      generator.int_uniform_inclusive(0, 2),
      generator.int_uniform_inclusive(10, 12),
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
  |> should.equal(Ok(Nil))
}

import gleam/string_builder

fn int_int_dict_to_string(d: dict.Dict(Int, Int)) -> String {
  dict.fold(d, string_builder.from_string("{ "), fn(sb, k, v) {
    string_builder.append(
      sb,
      int.to_string(k) <> " => " <> int.to_string(v) <> ", ",
    )
  })
  |> string_builder.append(" }")
  |> string_builder.to_string()
}

pub fn dict_generators_shrink_on_size_then_on_elements__test() {
  let #(tree, _seed) =
    generator.generate_tree(
      generator.dict_generic(
        key: generator.int_uniform_inclusive(0, 2),
        value: generator.int_uniform_inclusive(10, 12),
        max_length: 3,
      ),
      seed.new(2),
    )

  tree
  |> tree.to_string(int_int_dict_to_string)
  |> birdie.snap("dict_generators_shrink_on_size_then_on_elements__test")
}
