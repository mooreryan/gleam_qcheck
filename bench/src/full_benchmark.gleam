import argv
import birl.{type Time}
import birl/duration
import filepath
import gleam/int
import gleam/io
import gleam/string
import prng/seed
import qcheck
import simplifile
import youid/uuid

const test_count = 10_000

const long_test_run_count = 5

const medium_test_run_count = 20

const short_test_run_count = 500

type Category {
  Bools
  Characters
  Collections
  Floats
  Ignore
  Ints
  Nils
  Strings
}

fn category_to_string(category: Category) -> String {
  case category {
    Bools -> "Bools"
    Characters -> "Characters"
    Collections -> "Collections"
    Floats -> "Floats"
    Ignore -> "Ignore"
    Ints -> "Ints"
    Nils -> "Nils"
    Strings -> "Strings"
  }
}

fn category_run_count(category: Category) -> Int {
  case category {
    Bools -> short_test_run_count
    Characters -> short_test_run_count
    Collections -> long_test_run_count
    Floats -> short_test_run_count
    Ignore -> medium_test_run_count
    Ints -> short_test_run_count
    Nils -> short_test_run_count
    Strings -> medium_test_run_count
  }
}

pub fn main() {
  let assert [outdir] = argv.load().arguments
  let assert Ok(Nil) = simplifile.create_directory_all(outdir)

  let run_id = uuid.v7_string()

  let outfile = filepath.join(outdir, "bench_full__" <> run_id <> ".txt")

  io.println("outfile will be: " <> outfile)

  // Delete file if it exists.
  let _ = simplifile.delete(outfile)

  // Force the local function to be polymorphic in the generator.
  let run_bench = fn(category, name, generator: qcheck.Generator(a)) {
    run_bench(outfile:, run_id:)(category, name, generator)
  }

  // Write the header.
  let assert Ok(Nil) =
    "id|category|func|time|monotime\n" |> simplifile.write(to: outfile)

  // This first thing is to give the program time to "warnup", so we don't have
  // to discard the first 5 or so runs.
  run_bench(Ignore, "ignore", qcheck.string_from(qcheck.char()))

  // MARK: Characters

  run_bench(Characters, "char", qcheck.char())

  run_bench(
    Characters,
    "char_uniform_inclusive",
    qcheck.char_uniform_inclusive(low: 0, high: 100),
  )

  run_bench(Characters, "char_uppercase", qcheck.char_uppercase())

  run_bench(Characters, "char_lowercase", qcheck.char_lowercase())

  run_bench(Characters, "char_digit", qcheck.char_digit())

  run_bench(Characters, "char_print_uniform", qcheck.char_print_uniform())

  run_bench(Characters, "char_uniform", qcheck.char_uniform())

  run_bench(Characters, "char_alpha", qcheck.char_alpha())

  run_bench(Characters, "char_alpha_numeric", qcheck.char_alpha_numeric())

  run_bench(
    Characters,
    "char_from_list",
    qcheck.char_from_list([
      "a", "b", "c", "d", "e", "f", "0", "1", "2", "3", "4", "5", "6",
    ]),
  )

  run_bench(Characters, "char_whitespace", qcheck.char_whitespace())

  run_bench(Characters, "char_print", qcheck.char_print())

  // MARK: Strings

  run_bench(Strings, "string", qcheck.string())

  run_bench(Strings, "string_from(char)", qcheck.string_from(qcheck.char()))

  run_bench(Strings, "string_non_empty", qcheck.string_non_empty())

  run_bench(Strings, "string_with_length(10)", qcheck.string_with_length(10))

  run_bench(
    Strings,
    "string_with_length_from(char, 10)",
    qcheck.string_with_length_from(qcheck.char(), 10),
  )

  run_bench(
    Strings,
    "string_non_empty_from(char)",
    qcheck.string_non_empty_from(qcheck.char()),
  )

  run_bench(
    Strings,
    "string_generic(char, small_positive_or_zero_int)",
    qcheck.string_generic(qcheck.char(), qcheck.small_positive_or_zero_int()),
  )

  // MARK: Ints

  run_bench(Ints, "int_uniform", qcheck.int_uniform())

  run_bench(
    Ints,
    "int_uniform_inclusive",
    qcheck.int_uniform_inclusive(low: -100, high: 100),
  )

  run_bench(
    Ints,
    "small_positive_or_zero_int",
    qcheck.small_positive_or_zero_int(),
  )

  run_bench(
    Ints,
    "small_strictly_positive_int",
    qcheck.small_strictly_positive_int(),
  )

  // MARK: Floats

  run_bench(Floats, "float", qcheck.float())

  run_bench(
    Floats,
    "float_uniform_inclusive",
    qcheck.float_uniform_inclusive(-100.0, 100.0),
  )

  // MARK: Lists

  run_bench(
    Collections,
    "list_generic(char)",
    qcheck.list_generic(qcheck.char(), min_length: 10, max_length: 10),
  )

  run_bench(
    Collections,
    "list_generic(string)",
    qcheck.list_generic(qcheck.string(), min_length: 10, max_length: 10),
  )

  run_bench(
    Collections,
    "list_generic(int_uniform)",
    qcheck.list_generic(qcheck.int_uniform(), min_length: 10, max_length: 10),
  )

  run_bench(
    Collections,
    "list_generic(float)",
    qcheck.list_generic(qcheck.float(), min_length: 10, max_length: 10),
  )

  // MARK: Sets

  run_bench(
    Collections,
    "set_generic(char)",
    qcheck.set_generic(qcheck.char(), max_length: 10),
  )

  run_bench(
    Collections,
    "set_generic(string)",
    qcheck.set_generic(qcheck.string(), max_length: 10),
  )

  run_bench(
    Collections,
    "set_generic(int_uniform)",
    qcheck.set_generic(qcheck.int_uniform(), max_length: 10),
  )

  run_bench(
    Collections,
    "set_generic(float)",
    qcheck.set_generic(qcheck.float(), max_length: 10),
  )

  // MARK: Other

  run_bench(Bools, "bool", qcheck.bool())

  run_bench(Nils, "nil", qcheck.nil())

  run_bench(Strings, "option(string)", qcheck.option(qcheck.string()))

  run_bench(Ints, "option(int_uniform)", qcheck.option(qcheck.int_uniform()))

  run_bench(Floats, "option(float)", qcheck.option(qcheck.float()))
}

fn now() {
  #(birl.now(), birl.monotonic_now())
}

fn log(
  outfile: String,
  run_id: String,
  category: Category,
  msg: String,
  ts: #(Time, Int),
) {
  let #(prev_now, prev_monotonic_now) = ts
  let new_ts = now()
  let #(new_now, new_monotonic_now) = new_ts

  let duration = birl.difference(new_now, prev_now)
  let micros = duration.blur_to(duration, duration.MicroSecond)
  let monotonic_micros = new_monotonic_now - prev_monotonic_now

  let line =
    string.join(
      [
        run_id,
        category_to_string(category),
        msg,
        int.to_string(micros),
        int.to_string(monotonic_micros),
      ],
      "|",
    )
    <> "\n"

  let assert Ok(Nil) = line |> simplifile.append(to: outfile)

  new_ts
}

fn run(outfile, run_id, category, msg, i, f) {
  do_run(outfile, run_id, category, msg, i, now(), f)
}

fn do_run(outfile, run_id, category, msg, i, ts, f) {
  case i >= 0 {
    True -> {
      let _ = f()
      let ts = log(outfile, run_id, category, msg, ts)
      do_run(outfile, run_id, category, msg, i - 1, ts, f)
    }
    False -> Nil
  }
}

fn run_bench(
  outfile outfile: String,
  run_id run_id: String,
) -> fn(Category, String, qcheck.Generator(a)) -> Nil {
  fn(category: Category, name: String, generator: qcheck.Generator(a)) -> Nil {
    let run_count = category_run_count(category)

    run(outfile, run_id, category, name, run_count, fn() {
      qcheck.run(
        config: qcheck.default_config()
          |> qcheck.with_test_count(test_count)
          |> qcheck.with_random_seed(seed.new(1_234_132)),
        generator: generator,
        property: fn(_) { True },
      )
    })
  }
}
