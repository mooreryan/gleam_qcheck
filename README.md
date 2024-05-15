# qcheck

QuickCheck-inspired property-based testing with integrated shrinking for [Gleam](https://gleam.run/).

Rather than specifying test cases manually, you describe the invariants that values of a given type must satisfy ("properties").  Then, generators generate lots of values (test cases) on which the properties are checked.  Finally, if a value is found for which a given property does not hold, that value is "shrunk" in order to find an nice, informative counter-example that is presented to you.

While there are a ton of great articles introducing quickcheck or property-based testing, here are a couple general resources that you may enjoy:

- [An introduction to property based testing](https://fsharpforfunandprofit.com/pbt/)
- [What is Property Based Testing?](https://hypothesis.works/articles/what-is-property-based-testing/)

## Usage

The main modules that you will be interacting with are `qcheck/qtest` and `qcheck/generator`.

- `qcheck/qtest` contains the functions used to actually run the property tests.
  - `qcheck/qtest/config` contains functions and types for setting the configuration options for the property tests.
- `qcheck/generator` contains the functions used to generate the values that drive the property tests, as well as additional tools for creating your own generators.

### Example

Here is a short example to get you started.  It assumes you are using [gleeunit](https://github.com/lpil/gleeunit) to run the tests, but any test runner that reasonably handles panics will do.


```gleam
import qcheck/generator
import qcheck/qtest

pub fn small_positive_or_zero_int__test() {
  use n <- qtest.given(generator.small_positive_or_zero_int())
  n + 1 == 1 + n
}

pub fn small_positive_or_zero_int__failures_shrink_to_zero__test() {
    use n <- qtest.given(generator.small_positive_or_zero_int())
    n + 1 != 1 + n
}
```

That second example will fail with an error that may look something like this if you are targeting Erlang.

```
 Failures:

   1) qcheck/gen_int_test.small_positive_or_zero_int__failures_shrink_to_zero__test
      Failure: <<"TestError[original_value: 10; shrunk_value: 0; shrink_steps: 1;]">>
      stacktrace:
        qcheck_ffi.fail
      output: 
```

- `qtest.given` sets up the test
  - If a property holds for all generated values, then `qtest.given` returns `Nil`.
  - If a property does not hold for all generated values, then `qtest.given` will panic.
- `generator.small_positive_or_zero_int()` generates small integers greater than or equal to zero.
- `n + 1 == 1 + n` is the property being tested in the first test.
  - It should be true for all generated values.
  - The return value of `qtest.given` will be `Nil`, because the property does hold for all generated values.
- `n + 1 != 1 + n` is the property being tested in the second test. 
  - It should be false for all generated values.
  - `qtest.given` will be panic, because the property does not hold for all generated values.

#### More examples

The [test](https://github.com/mooreryan/gleam_qcheck/tree/main/test) directory of this repository has many examples of setting up tests, using the built-in generators, and creating new generators.  Until more dedicated documentation is written, the tests can provide some good info, as they exercise most of the available behavior of the `qtest` and `generator` modules.  However, be aware that the tests will often use `use <- err.rescue`.  This is *not* needed in your tests--it provides a way to test the `qcheck` internals.

### Integrating with testing frameworks

You don't have to do anything special to integrate `qcheck` with a testing framework like [gleeunit](https://github.com/lpil/gleeunit).  The only thing required is that your testing framework of choice be able to check the return values of `qtest.run` (or `qtest.run_result`).

You may also be interested in [qcheck_gleeunit_utils](https://github.com/mooreryan/qcheck_gleeunit_utils) for running your tests in parallel.

## Roadmap

While `qcheck` has a lot of features needed to get started with property-based testing, there are still things that could be added or improved.

See the `ROADMAP.md` for more information.

## Acknowledgements

Very heavily inspired by the [qcheck](https://github.com/c-cube/qcheck) and [base_quickcheck](https://github.com/janestreet/base_quickcheck) OCaml packages, and of course, the Haskell libraries from which they take inspiration.

## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.


