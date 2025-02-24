import gleam/list
import gleeunit/should
import qcheck

pub fn generate__test() {
  let #(numbers, _seed) =
    qcheck.generate(qcheck.bounded_int(-10, 10), 100, qcheck.random_seed())

  let result = {
    use number <- list.all(numbers)
    -10 <= number && number <= 10
  }

  result |> should.be_true
  list.length(numbers) |> should.equal(100)
}
