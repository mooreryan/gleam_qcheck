check:
  gleam check

testw:
  watchexec --no-process-group gleam test

test:
  gleam test

test_review:
  gleam run -m birdie

find_todos:
  rg -g '!build' -g '!justfile' -i todo