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
  - commit: "Speed up `small_positive_or_zero_int`"
  - cimmit hash: `72c4f1d5f624d0d3d4453248f5d27ea762eae7ed`

### Replace `random.choose` with `prng_random.choose`

- before
  - `01921829-EEA0-7D88-B98B-2EC7EC86ABDC`
- after
  - `01922088-7FB3-7455-949B-6DE73D00A84B`

This affects bool and float generation.
