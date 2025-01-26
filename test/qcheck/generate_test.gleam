import gleam/list
import gleeunit/should
import qcheck

pub fn generate__test() {
  let numbers =
    qcheck.generate(
      qcheck.int_uniform_inclusive(-10, 10),
      100,
      qcheck.seed_random(),
    )

  let result = {
    use number <- list.all(numbers)
    -10 <= number && number <= 10
  }

  result |> should.be_true
  list.length(numbers) |> should.equal(100)
}
