import birdie
import gleam/int
import gleam/list
import gleam/string
import gleeunit/should
import prng/seed
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/tree

pub fn list_generic__generates_valid_values__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.list_generic(
      generator.int_uniform_inclusive(-5, 5),
      min_length: 2,
      max_length: 5,
    ),
    property: fn(l) {
      let len = list.length(l)
      2 <= len && len <= 5 && list.all(l, fn(n) { -5 <= n && n <= 5 })
    },
  )
  |> should.equal(Ok(Nil))
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
    generator.generate_tree(
      generator.list_generic(
        generator.int_uniform_inclusive(-1, 2),
        min_length: 0,
        max_length: 3,
      ),
      seed.new(10_003),
    )

  tree
  |> tree.to_string(int_list_to_string)
  |> birdie.snap("list_generators_shrink_on_size_then_on_elements__test")
}
