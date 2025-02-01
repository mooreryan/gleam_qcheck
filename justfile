check:
  gleam check

check_no_cache:
  rm -r build/dev/*/qcheck; gleam check

checkw:
  watchexec --no-process-group gleam check

testw:
  watchexec --no-process-group gleam test

test:
  #!/usr/bin/env bash
  set -euxo pipefail

  gleam test
  gleam test --target=javascript

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
  mkdir -p dist/priv/static
  gleam run -m lustre/dev build --outdir=dist/priv/static --minify
  mv dist/priv/static/qcheck_viewer.min.mjs \
     dist/priv/static/qcheck_viewer.mjs
  cp index.html dist

qv_setup_for_gh_pages:
  #!/usr/bin/env bash
  set -euxo pipefail

  cd qcheck_viewer

  npm install
  gleam deps download

# Find the `name` in the code.
find name:
  rg {{ name }} -g '*.gleam' src/ test/

# You SHOULD have a clean working directory (git) and run `find name` first to verify.
rename current_name new_name:
  rg {{ current_name }} -l -0 -g '*.gleam' src/ test/ | xargs -0 sed -i '' 's/{{ current_name }}/{{ new_name }}/g'
