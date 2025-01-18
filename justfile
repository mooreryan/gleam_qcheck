check:
  gleam check

check_no_cache:
  rm -r build/dev/*/qcheck; gleam check

checkw:
  watchexec --no-process-group gleam check

testw:
  watchexec --no-process-group gleam test

test:
  gleam test

test_review:
  gleam run -m birdie

find_todos:
  rg -g '!build' -g '!justfile' -i todo

bench_full:
  #!/usr/bin/env bash
  set -euxo pipefail

  cd bench 

  gleam run -m full_benchmark -- bench_out

qv_dev:
  #!/usr/bin/env bash
  set -euxo pipefail

  cd qcheck_viewer

  gleam run -m lustre/dev start

qv_test:
  #!/usr/bin/env bash
  set -euxo pipefail

  cd qcheck_viewer

  gleam test

qv_build_site:
  #!/usr/bin/env bash
  set -euxo pipefail

  cd qcheck_viewer

  if [ -d dist ]; then rm -r dist; fi
  gleam run -m lustre/dev build --outdir=dist --minify
  cp index.html dist

qv_setup_for_gh_pages:
  #!/usr/bin/env bash
  set -euxo pipefail

  cd qcheck_viewer
  
  gleam deps download
  gleam test --target=javascript
