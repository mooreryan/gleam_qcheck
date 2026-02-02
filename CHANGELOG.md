# Changelog

## [Unreleased]

## [1.0.4] -- 2026-02-01

- Update prng dependency to v5.0.0

## [1.0.3] -- 2026-01-06

- Better error reporting. The errors used to look something like this:

```
bsql3_test.coerce_roundtrip_test
An unexpected error occurred:

  //js(Error: TestError[original_value: #(Some(287951460), Some(-117181.6780709644), Some(True), Some("uvESV5N"), Some(<<>>)); shrunk_value: #(Some(0), None, None, None, None); shrink_steps: 5; error: Errored(//js(Error: Assertion failed.));])
```

Now, you might get something that looks like this:

```
panic src/qcheck.gleam:2839
 test: bsql3_test.coerce_roundtrip_test
 info: a property was falsified!
qcheck assert test/bsql3_test.gleam:287
 code: assert row == #(None, a_float, a_bool, some_text, a_blob)
 left: #(Some(1371457222), Some(369023.1034975077), Some(True), Some("2x"), None)
right: #(None, Some(369023.1034975077), Some(True), Some("2x"), None)
 info: Assertion failed.
qcheck shrinks
 orig: #(Some(1371457222), Some(369023.1034975077), Some(True), Some("2x"), None)
 shrnk: #(Some(0), None, None, None, None)
 steps: 4
```

## [1.0.2] -- 2025-11-03

- Remove an unused argument in a private function
  - This addresses the warning that shows up when users upgrade to Gleam v1.13

## [1.0.1] -- 2025-10-01

- Update Gleam stdlib and other deps
- Replace deprecated `result.then` with `result.try`

## [1.0.0] -- 2025-03-01

- Major rewrite of the public API
- Not backward compatible with pre-1.0 versions

<details>
<summary>Pre-1.0 Versions</summary>

- [0.0.8](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.8) -- 2024-12-31
- [0.0.7](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.7) -- 2024-12-11
- [0.0.6](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.6) -- 2024-09-30
- [0.0.5](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.5) -- 2024-09-23
- [0.0.4](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.4) -- 2024-09-16
- [0.0.3](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.3) -- 2024-05-15
- [0.0.2](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.2) -- 2024-05-06
- [0.0.1](https://github.com/mooreryan/gleam_qcheck/releases/tag/v0.0.1) -- 2024-04-28

</details>

[Unreleased]: https://github.com/mooreryan/gleam_qcheck/compare/v1.0.4...HEAD
[1.0.3]: https://github.com/mooreryan/gleam_qcheck/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/mooreryan/gleam_qcheck/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/mooreryan/gleam_qcheck/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/mooreryan/gleam_qcheck/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/mooreryan/gleam_qcheck/compare/v0.0.8...v1.0.0

```

```
