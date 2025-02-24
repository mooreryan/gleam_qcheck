import gleam/string
import qcheck

const test_count: Int = 2500

pub fn using_use__test() {
  let generator = {
    use n <- qcheck.map(qcheck.small_non_negative_int())
    n + 10
  }

  use n <- qcheck.given(generator)
  n >= 10
}

type Person {
  Person(name: String, age: Int)
}

fn make_person(name, age) {
  let name = case name {
    "" -> Error("name must be a non-empty string")
    name -> Ok(name)
  }

  let age = case age >= 0 {
    False -> Error("age must be >= 0")
    True -> Ok(age)
  }

  case name, age {
    Ok(name), Ok(age) -> Ok(Person(name, age))
    Error(e), Ok(_) | Ok(_), Error(e) -> Error([e])
    Error(e1), Error(e2) -> Error([e1, e2])
  }
}

fn valid_name_and_age_generator() {
  let name_generator = qcheck.non_empty_string()
  let age_generator = qcheck.bounded_int(from: 0, to: 129)

  use name, age <- qcheck.map2(name_generator, age_generator)
  #(name, age)
}

pub fn person__test() {
  use #(name, age) <- qcheck.run_result(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: valid_name_and_age_generator(),
  )

  make_person(name, age)
}

pub fn bind_with_use__test() {
  let generator = {
    use bool <- qcheck.bind(qcheck.bool())

    case bool {
      True -> {
        use n <- qcheck.map(qcheck.small_non_negative_int())
        Ok(n)
      }
      False -> {
        use s <- qcheck.map(qcheck.non_empty_string())
        Error(s)
      }
    }
  }

  use generated_value <- qcheck.run(
    config: qcheck.default_config() |> qcheck.with_test_count(test_count),
    generator: generator,
  )

  case generated_value {
    Ok(n) -> n >= 0
    Error(s) -> string.length(s) >= 0
  }
}
