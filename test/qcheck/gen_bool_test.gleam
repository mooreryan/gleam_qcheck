import birdie
import gleam/bool
import prng/seed
import qcheck/generator
import qcheck/tree

pub fn bool_true_shrink_tree__test() {
  let #(tree, _seed) =
    generator.generate_tree(
      generator.bool(),
      // Don't change this seed--it generates `True` to start.
      seed.new(5),
    )

  tree
  |> tree.to_string(bool.to_string)
  |> birdie.snap("bool_true_shrink_tree__test")
}
