# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `constant`: a synonym for `qcheck.return`
- `sized_from`

### Changed

- Function signature changes in `from_generators`, `from_float_weighted_generators`, and `from_weighted_generators`.
  - These functions were called as `from_generators([g1, g2, ...])`.
  - Now they are called as `from_generators(g1, [g2, g3, ...])` to ensure one generator is always provided.
- `char_from_list(["a", "b", "c"])` is now `char_from_list("a", ["b", "c"])` to address the same issue present in the `from_generators` functions.
- Require `prng` >= 4.0.1 (#7)
- Improved generation and shrinking of bit arrays
- `int_uniform_inclusive` and `float_uniform_inclusive`
  - Changed named args:
    - `low` -> `from`
    - `high` -> `to`
  - No longer panics if the first arg is less than the second arg
- The `Config` type is now opaque
- These functions are now private:
  - `failwith`
  - `try`
  - `rescue_error`
- These functions are now internal:
  - `rescue`
- These functions have been renamed:
  - `char_print` -> `char_printable`
  - `char_print_uniform` -> `char_printable_uniform`
  - `seed_new` -> `seed`
  - `sequence_list` -> `sequence_trees`
  - `with_random_seed` -> `with_seed`
- Changes to the `map` family of functions:
  - The function argument `f` is now in the last position so that you can use `use` sugar without needing to specify label names.
  - Label names have been removed.
  - Reinstanted `map4`, `map5`, and `map6`.
    - Lower down in the changelog, it mentions it is better to use the applicative style, but sometimes it is convenient to just use these and be done with it.

### Fixed

- Fix some tests that were broken on JS target
- Fix a bug in `int_small_positive_or_zero`

## [0.0.8] - 2024-12-31

### Added

- `BitArray` generators
- `UtfCodepoint` (unicode codepoint) generator
- `char_utf_codepoint` which can be used in string generators to generate strings composed of valid unicode codepoints

### Changed

- These functions have been renamed to fit with the `type_modifier` naming scheme:
  - `small_positive_or_zero_int` -> `int_small_positive_or_zero`
  - `small_strictly_positive_int` -> `int_small_strictly_positive`

## [0.0.7] - 2024-12-11

### Changed

- Addressed deprecations
  - `iterator` => `yielder`
  - `regex` => `regexp`
  - `string_builder` => `string_tree`

## [0.0.6] - 2024-09-30

### Added

- `qcheck.parameter` to simplify the creation of curried function for the applicative style of building generators.

### Changed

- All occurrences of `prng/seed.Seed` type have been replaced with `qcheck.Seed`.

### Removed

- Removed `map4`, `map5`, and `map6` from the `qcheck` module. (It is better to use the applicative style with `qcheck.parameter` and `use`.)

## [0.0.5] - 2024-09-23

### Added

- `qcheck.from_float_weighted_generators`
  - This function was previously called `qcheck.from_weighted_generators`.

### Changed

- Changed the implementation of `small_positive_or_zero_int`, which results in a >2x speed up of many of the string generators.
- Replace some of the `prng` random functions with internal implementations based on integer generation, which speeds up generators that depend on them.
  - Replace `prng/random.choose`, which speeds up the float and bool generation.
  - Replace `prng/random.uniform`, which speeds up the generators that depend on `from_generators` or `char_from_list`.
  - Replace `prng/random.weighted`.
- `qcheck.from_weighted_generators` now takes integer weights rather than float weights.
- The default test count for `qcheck.default_config` is 1000 now rather than 10,000.

### Fixed

- Fixed a bug in the calling of JS FFI.

## [0.0.4] - 2024-09-16

### Added

- Top-level `qcheck` module
  - All public functionality now lives in this module.
  - Any other modules should be considered internal or private.

### Changed

- `dict_generic` uses a minimum size of `0` rather than `1`.
- Though most functions moved into the `qcheck` module with their original name, some were renamed. Here are a few of the important ones.
  - `qcheck/qtest/config.default` -> `qcheck.default_config`
  - `qcheck/generator.make_primitive` -> `qcheck.make_primitive_generator`
  - `qcheck/shrink` functions are now prefixed with `shrink_`, e.g., `qcheck.shrink_int_towards_zero`.
  - `qcheck/tree`
    - `apply` -> `qcheck.apply_tree`
    - `bind` -> `qcheck.bind_tree`
    - `iterator_list` -> `qcheck.sequence_list`
    - `make_primitive` -> `qcheck.make_primitive`
    - `map` -> `qcheck.map_tree`
    - `map2` -> `qcheck.map2_tree`
    - `option` -> `qcheck.option_tree`
    - `return` -> `qcheck.return_tree`
    - `to_string` -> `qcheck.tree_to_string`
- Some public types and functions were made private
  - All public functions that were in `qcheck/utils`
  - `qcheck/shrink`
    - `do_shrink`
    - `do_shrink_result`
    - `shrink`
    - `do_shrink`

### Removed

These public functions and types were removed.

- `qcheck/qtest/test_error.new_string_repr`
- `qcheck/qtest/test_error.TestErrorDisplay`

## [0.0.3] - 2024-05-15

### Added

- `qtest.given` and `qtest.given_result` functions for running property tests with the default configuration.

### Changed

- `qtest.run` and `qtest.run_result` now both return `Nil` on property success, and panic on property failure.
  - Panics inside property functions are treated as property failures and are handled, which allows shrinking to occur.
    - This allows users to use assertions to bail out of a test at any time when it is more convenient to do so.
    - Also, it removes the need to check that `run` and `run_result` return `Ok(Nil)` to signal a successful property. Rather, no further action needs to be taken on success, as failures will panic, which should be handled by the testing framework.
  - Property success/failure
    - `qtest.run` now fails ether if the property returns `False` or if there is a panic in the property.
    - `qtest.run_result` now fails ether if the property returns `Error` or if there is a panic in the property.
- Shrinking functions return the number of shrink steps along with the shrunk value.
- Counter-example info now includes original value, shrunk value, shrink steps, and the relevant error message.

## [0.0.2] - 2024-05-06

### Added

- Add `float_uniform_inclusive` generator

### Changed

- Change argument names and labelled arguments
- Improve performance of character generators `char`, `char_print`, and `char_alpha_numeric`

## [0.0.1] - 2024-04-28

- Initial release!

[Unreleased]: https://github.com/mooreryan/gleam_qcheck/compare/v0.0.8...HEAD
[0.0.8]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.8
[0.0.7]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.7
[0.0.6]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.6
[0.0.5]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.5
[0.0.4]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.4
[0.0.3]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.3
[0.0.2]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.2
[0.0.1]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.1
