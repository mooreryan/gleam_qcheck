# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

NA

## [0.0.3] - 2024-05-15

### Added

- `qtest.given` and `qtest.given_result` functions for running property tests with the default configuration.

### Changed

- `qtest.run` and `qtest.run_result` now both return `Nil` on property success, and panic on property failure.
  - Panics inside property functions are treated as property failures and are handled, which allows shrinking to occur.
    - This allows users to use assertions to bail out of a test at any time when it is more convenient to do so.
    - Also, it removes the need to check that `run` and `run_result` return `Ok(Nil)` to signal a successful property.  Rather, no further action needs to be taken on success, as failures will panic, which should be handled by the testing framework.
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


[unreleased]: https://github.com/mooreryan/gleam_qcheck/compare/v0.0.3...HEAD
[0.0.3]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.3
[0.0.2]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.2
[0.0.1]: https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.1
