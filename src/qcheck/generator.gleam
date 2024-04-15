import gleam/int
import gleam/option.{type Option, None}
import prng/random
import prng/seed.{type Seed}
import qcheck/shrink
import qcheck/tree.{type Tree, Tree}

pub type Generator(a) {
  Generator(fn(Seed) -> #(Tree(a), Seed))
}

fn make_primative(
  random_generator random_generator: random.Generator(a),
  make_tree make_tree: fn(a) -> Tree(a),
) -> Generator(a) {
  Generator(fn(seed) {
    let #(generated_value, next_seed) = random.step(random_generator, seed)

    #(make_tree(generated_value), next_seed)
  })
}

pub fn map(generator: Generator(a), f: fn(a) -> b) -> Generator(b) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(tree, seed) = generate(seed)

    let tree = tree.map(tree, f)

    #(tree, seed)
  })
}

pub fn small_positive_or_zero_int() -> Generator(Int) {
  make_primative(
    random_generator: random.float(0.0, 1.0)
      |> random.then(fn(x) {
        case x <. 0.75 {
          True -> random.int(0, 10)
          False -> random.int(0, 100)
        }
      }),
    make_tree: fn(n) {
      tree.make_primative(root: n, shrink: shrink.int_towards_zero())
    },
  )
}

pub fn small_strictly_positive_int() -> Generator(Int) {
  small_positive_or_zero_int()
  |> map(int.add(_, 1))
}

// TODO: doesn't hit the interesting cases very often.  Use something more like
//   qcheck2 or base_quickcheck.
pub fn int_uniform() -> Generator(Int) {
  make_primative(
    random_generator: random.int(random.min_int, random.max_int),
    make_tree: fn(n) {
      tree.make_primative(root: n, shrink: shrink.int_towards_zero())
    },
  )
}

type GenerateOption {
  GenerateNone
  GenerateSome
}

fn generate_option() -> random.Generator(GenerateOption) {
  random.weighted(#(0.15, GenerateNone), [#(0.85, GenerateSome)])
}

/// `option(generator)` shrinks towards `None` then towards shrinks of
/// `generator`. 
pub fn option(generator: Generator(a)) -> Generator(Option(a)) {
  let Generator(generate) = generator

  Generator(fn(seed) {
    let #(generate_option, seed) = random.step(generate_option(), seed)

    case generate_option {
      GenerateNone -> #(tree.return(None), seed)
      GenerateSome -> {
        let #(tree, seed) = generate(seed)

        #(tree.option(tree), seed)
      }
    }
  })
}
