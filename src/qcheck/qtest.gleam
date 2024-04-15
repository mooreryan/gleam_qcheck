import qcheck/generator.{type Generator, Generator}
import qcheck/qtest/config.{type Config} as qtest_config
import qcheck/shrink
import qcheck/tree.{type Tree, Tree}

fn do_run(
  config: Config,
  generator: Generator(a),
  property: fn(a) -> Bool,
  i: Int,
) -> Result(Nil, a) {
  case i >= config.test_count {
    True -> Ok(Nil)
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(config.random_seed)
      let Tree(value, _shrinks) = tree

      case property(value) {
        True ->
          do_run(
            config
              |> qtest_config.with_random_seed(seed),
            generator,
            property,
            i + 1,
          )
        False -> {
          let shrunk_value =
            shrink.shrink(
              tree,
              property,
              run_property_max_retries: config.max_retries,
            )
          Error(shrunk_value)
        }
      }
    }
  }
}

pub fn run(
  config config: Config,
  generator generator: Generator(a),
  property property: fn(a) -> Bool,
) -> Result(Nil, a) {
  do_run(config, generator, property, 0)
}

fn do_run_result(
  config: Config,
  generator: Generator(a),
  property: fn(a) -> Result(b, error),
  i: Int,
) -> Result(Nil, a) {
  case i >= config.test_count {
    True -> Ok(Nil)
    False -> {
      let Generator(generate) = generator
      let #(tree, seed) = generate(config.random_seed)
      let Tree(value, _shrinks) = tree

      case property(value) {
        Ok(_) ->
          do_run_result(
            config
              |> qtest_config.with_random_seed(seed),
            generator,
            property,
            i + 1,
          )
        Error(_) -> {
          let shrunk_value =
            shrink.shrink_result(
              tree,
              property,
              run_property_max_retries: config.max_retries,
            )
          Error(shrunk_value)
        }
      }
    }
  }
}

pub fn run_result(
  config config: Config,
  generator generator: Generator(a),
  property property: fn(a) -> Result(b, error),
) -> Result(Nil, a) {
  do_run_result(config, generator, property, 0)
}
