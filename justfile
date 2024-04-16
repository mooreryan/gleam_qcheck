check:
  gleam check

test:
  gleam test

test_review:
  gleam run -m birdie

find_todos:
  rg -g '!build' -g '!justfile' -i todo