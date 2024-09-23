# qcheck_bench

_Note to self: don't forget to plug in my laptop for comparitive timing based tests, as it affects the timings._

## Running fprof and erlgrind

Note that this can take a while, so keep the values reasonable.

In the `gleam shell`:

```
c(for_fprof).
fprof:start().
fprof:trace(start).
for_fprof:main().
fprof:trace(stop).
fprof:profile().
fprof:analyse({dest, "outfile.fprof"}).
```

Then run

```
./scripts/erlgrind outfile.fprof outfile.cgrind
kcachegrind outfile.cgrind
```

## Speed ups

Some specific speedups have accopanying charts or stats. For reference, some of these are listed here.

- The git commit hashes refer to the main qcheck repo.
- UUIDs are for identifying benchmark runs in the output files.

### Speed up `small_positive_or_zero_int`

- before
  - `019217B1-4B6E-7F85-9551-FC663C27CC93`
- after
  - `01921829-EEA0-7D88-B98B-2EC7EC86ABDC`
  - commit hash: `72c4f1d5f624d0d3d4453248f5d27ea762eae7ed`
  - commit msg: "Speed up `small_positive_or_zero_int`"

### Replace `random.choose` with `prng_random.choose`

- before
  - `01921829-EEA0-7D88-B98B-2EC7EC86ABDC`
- after
  - `01922088-7FB3-7455-949B-6DE73D00A84B`
  - commit hash: `592b50caab2b85aeb257651c73000b6500082182`
  - commit msg: "Replace `random.choose` with internal implementation"

This affects bool and float generation.

### Replace `random.uniform` with `prng_random.uniform`

- before
  - `01922088-7FB3-7455-949B-6DE73D00A84B`
- after
  - `019220A8-C09F-72D9-9DA3-27D8306F6067`
  - commit hash: `TODO`
  - commit msg: "TODO"

This affects `char_from_list` and `from_generators`.

Charts: `Rscript --vanilla bench/scripts/plot_bench_results.R bench/bench_out/bench_full__0192*txt.gz`
