# Roadmap

## Generators

- Some generators could use better "tuning".
  - Ensure common generators hit the corner cases with a high enough frequency.
  - Consider more or alternative generators from:
    - [random-generator](https://github.com/gasche/random-generator)
    - [base_quickcheck](https://github.com/janestreet/base_quickcheck)

### Generation strategies

- These types all have generators, but could use more convenience functions:
  - `Dict` generators
  - `Float` generators
  - `List` generators
    - `list_with_length_from`: this one will never shrink on length
  - `Set` generators
- [x] Add generators for `bit_array`
- Combinators
  - `bind2`
- State-machine testing as in [qcstm](https://github.com/jmid/qcstm)
- Handle recursive data types. See:
  - [QCheck2.Gen.Fix](https://ocaml.org/p/qcheck-core/latest/doc/QCheck2/Gen/index.html#recursive-data-structures)
  - [Generating Recursive Values](https://ocaml.org/p/base_quickcheck/latest/doc/Base_quickcheck/Generator/index.html#generating-recursive-values)
- Observers. See:
  - [Observer](https://ocaml.org/p/base_quickcheck/latest/doc/Base_quickcheck/Observer/index.html)
  - [Observable](https://ocaml.org/p/qcheck-core/latest/doc/QCheck2/Observable/index.html)
  - The section on Observers from [here](https://blog.janestreet.com/quickcheck-for-core/)

### Char and String generators

- Speed up the `String` generators. (These are currently quite slow!)
  - (This has gotten better in `v0.0.2` and `v0.0.5`.)
- "Char" generators
  - Figure out better defaults for the "char" generators.
    - Right now they are focused on ascii characters mainly.
    - `v0.0.8` introduced `char_utf_codepoint` ... maybe it should be the defualt char generator for strings?
  - Having "char" generators is a little weird in a language without a `Char` type, but they are currently needed for generating and shrinking strings.
  - Some of the char generators take integers representing codepoints, but this is kind of awkward to work with.

### Shrinking

- Need to make it easier to turn off shrinking at certain points.
  - Either by swapping in the `atomic` shrinker, or
  - Making a `config` option to turn shrinking off for a particular `run` or `given` callback.

## Project structure

- [x] Consider a reorg of the modules.
- Finalize which functions are part of the public API.
- Finalize the named arguments.

## Counter-examples

- Include more info (other than just the shrunk value) in counter-examples.
  - (`v0.0.3`) Now includes the original failing example, shrink steps, and any captured error messages or exceptions.
  - However, the format of the presented data is not very user-friendly.
- The counter-example info looks different on the Erlang and JavaScript targets.

## Other stuff

- There are some places that use `let assert` to check for errors, especially checking for bad arguments. These should be addressed.
  - Also, when appropriate, function arguments should be validated and good errors should be returned.
- [x] Tests counts in the `config` that are too high can cause timeouts in Gleeunit if you aren't using helpers from [qcheck_gleeunit_utils](https://github.com/mooreryan/qcheck_gleeunit_utils)
  - Default test count was dropped to 1000 in `v0.0.5`.
- [x] Don't leak the `prng` types.
  - `v0.0.6` addressed this
- Some of the tests fail on JS target.
  - Mostly in the order of shrinking, so likely not too serious.
