import domino
import gleam/dynamic/decode
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn text_test() {
  domino.from_string("<p>Hello, </p><p>World!</p>")
  |> domino.select("p")
  |> domino.text()
  |> should.equal("Hello, World!")
}

pub fn attr_test() {
  domino.from_string("<p class='first'>Hello, </p><p class='second'>World!</p>")
  |> domino.select("p")
  |> domino.attr("class")
  |> should.equal("first")
}

pub fn attrs_test() {
  let attrs =
    domino.from_string(
      "<p class='first greeting' style='color: purple; font-weight: bold'>
        Hello, 
      </p>
      <p class='second greeting' style='color: blue; font-weight: bold'>
        World!
      </p>",
    )
    |> domino.select("p")
    |> domino.attrs()

  let decoder = {
    use class <- decode.field("class", decode.string)
    use style <- decode.field("style", decode.string)
    decode.success(#(class, style))
  }

  decode.run(attrs, decoder)
  |> should.equal(Ok(#("first greeting", "color: purple; font-weight: bold")))
}

pub fn length_test() {
  domino.from_string("<p>Hello, </p><p>World!</p>")
  |> domino.select("p")
  |> domino.length
  |> should.equal(2)
}

pub fn length_1_test() {
  domino.from_string("<p>Hello, </p><p>World!</p>")
  |> domino.select("div")
  |> domino.length
  |> should.equal(0)
}
