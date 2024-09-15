import birdie
import gleam/bool
import prng/seed
import qcheck

pub fn bool_true_shrink_tree__test() {
  let #(tree, _seed) =
    qcheck.generate_tree(
      qcheck.bool(),
      // Don't change this seed--it generates `True` to start.
      seed.new(5),
    )

  tree
  |> qcheck.tree_to_string(bool.to_string)
  |> birdie.snap("bool_true_shrink_tree__test")
}
