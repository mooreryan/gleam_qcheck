# qcheck

QuickCheck-inspired property testing with integrated shrinking for [Gleam](https://gleam.run/).

## Roadmap

- More convenience functions for 
  - `Dict` generators
  - `Float` generators
  - `List` generators
  - `Set` generators
- Generators for `bit_array`?
- Consider more generators from:
  - [random-generator](https://github.com/gasche/random-generator) 
  - [base_quickcheck](https://github.com/janestreet/base_quickcheck)
- Ensure common generators hit the corner cases with a high enough frequency.
- Speed up the `String` generators.  (These are currently quite slow!)
- "Char" generators
  - Figure out better defaults for the "char" generators.  Right now they are focused on ascii characters mainly.
  - Having "char" generators is a little weird in a language without a `Char` type, but they are currently needed for generating and shrinking strings.
- There are some place that use `let assert` to check for errors, especially checking for bad arguments.  These should be addressed.
  - Also, when appropriate, function arguments should be validated and good errors should be returned.
- Tests counts in `qtest/config` that are too high can cause timeouts.
- Include more info (other than just the shrunk value) in counter-examples (see QCheck2).
- State-machine testing as in [qcstm](https://github.com/jmid/qcstm)
- Handle recursive data types.  See:
  - [QCheck2.Gen.Fix](https://ocaml.org/p/qcheck-core/latest/doc/QCheck2/Gen/index.html#recursive-data-structures)
  - [Generating Recursive Values](https://ocaml.org/p/base_quickcheck/latest/doc/Base_quickcheck/Generator/index.html#generating-recursive-values)
- Observers. See:
  - [Observer](https://ocaml.org/p/base_quickcheck/latest/doc/Base_quickcheck/Observer/index.html)
  - [Observable](https://ocaml.org/p/qcheck-core/latest/doc/QCheck2/Observable/index.html)
  - The section on Observers from [here](https://blog.janestreet.com/quickcheck-for-core/)

## Acknowledgements

Very heavily inspired by the [qcheck](https://github.com/c-cube/qcheck) and [base_quickcheck](https://github.com/janestreet/base_quickcheck) OCaml packages.

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.


