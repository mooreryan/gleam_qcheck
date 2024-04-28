import birdie
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import gleeunit/should
import prng/seed
import qcheck/generator
import qcheck/qtest
import qcheck/qtest/config as qtest_config
import qcheck/tree

pub fn set_generic__generates_valid_values__test() {
  qtest.run(
    config: qtest_config.default(),
    generator: generator.set_generic(
      generator.int_uniform_inclusive(-5, 5),
      max_length: 5,
    ),
    property: fn(s) {
      let len = set.size(s)
      let correct_elements =
        set.to_list(s)
        |> list.all(fn(n) { -5 <= n && n <= 5 })
      len <= 5 && correct_elements
    },
  )
  |> should.equal(Ok(Nil))
}

fn int_set_to_string(s) {
  "["
  <> {
    set.to_list(s)
    |> list.map(int.to_string)
    |> string.join(",")
  }
  <> "]"
}

// Note: the shrinks don't look quite as you would expect compared to the list
// test because sets cannot have duplicates as the lists can.
pub fn set_generators_shrink_on_size_then_on_elements__test() {
  let #(tree, _seed) =
    generator.generate_tree(
      generator.set_generic(
        generator.int_uniform_inclusive(-1, 2),
        max_length: 3,
      ),
      seed.new(10_003),
    )

  tree
  |> tree.to_string(int_set_to_string)
  |> birdie.snap("set_generators_shrink_on_size_then_on_elements__test")
}
