import gleam/int
import gleam/json
import gleam/option
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import qcheck

// TODO: char_utf_codepoint crashes the histogram

const default_int_range_low: Int = -100

const default_int_range_high: Int = 100

pub const max_int: Int = 2_147_483_647

pub const min_int: Int = -2_147_483_648

pub const id_error_message = "error-message"

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MARK: Model

pub type Model {
  Model(
    function: QcheckFunction,
    int_range_low: Int,
    int_range_high: Int,
    error_message: option.Option(String),
  )
}

pub fn default_model() -> Model {
  Model(
    function: IntUniform,
    int_range_low: default_int_range_low,
    int_range_high: default_int_range_high,
    error_message: option.None,
  )
}

pub type QcheckFunction {
  IntUniform
  IntUniformInclusive
  IntSmallPositiveOrZero
  IntSmallStrictlyPositive
  Float
  FloatUniformInclusive
  Char
  CharUniform
  CharUniformInclusive
  CharUtfCodepoint
  CharUppercase
  CharLowercase
  CharDigit
  CharPrintUniform
  CharAlpha
  CharAlphaNumeric
  CharWhitespace
  CharPrint
}

fn qcheck_function_html_options(
  model_function: QcheckFunction,
) -> List(element.Element(_)) {
  [
    qcheck_function_to_html_option(
      IntSmallPositiveOrZero,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(
      IntSmallStrictlyPositive,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(IntUniform, current_function: model_function),
    qcheck_function_to_html_option(
      IntUniformInclusive,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(Float, current_function: model_function),
    qcheck_function_to_html_option(
      FloatUniformInclusive,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(Char, current_function: model_function),
    qcheck_function_to_html_option(
      CharUniform,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(
      CharUniformInclusive,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(
      CharUtfCodepoint,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(
      CharUppercase,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(
      CharLowercase,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(CharDigit, current_function: model_function),
    qcheck_function_to_html_option(
      CharPrintUniform,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(CharAlpha, current_function: model_function),
    qcheck_function_to_html_option(
      CharAlphaNumeric,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(
      CharWhitespace,
      current_function: model_function,
    ),
    qcheck_function_to_html_option(CharPrint, current_function: model_function),
  ]
}

fn qcheck_function_to_html_option(
  qcheck_function: QcheckFunction,
  current_function current_function: QcheckFunction,
) -> element.Element(_) {
  html.option(
    [
      qcheck_function_to_attribute(qcheck_function),
      attribute.selected(qcheck_function == current_function),
    ],
    qcheck_function_to_string(qcheck_function),
  )
}

pub fn qcheck_function_to_string(qcheck_function: QcheckFunction) -> String {
  case qcheck_function {
    IntUniform -> "int_uniform"
    IntUniformInclusive -> "int_uniform_inclusive"
    IntSmallStrictlyPositive -> "int_small_strictly_positive"
    IntSmallPositiveOrZero -> "int_small_positive_or_zero"
    Float -> "float"
    FloatUniformInclusive -> "float_uniform_inclusive"
    Char -> "char"
    CharUniform -> "char_uniform"
    CharUniformInclusive -> "char_uniform_inclusive"
    CharUtfCodepoint -> "char_utf_codepoint"
    CharUppercase -> "char_uppercase"
    CharLowercase -> "char_lowercase"
    CharDigit -> "char_digit"
    CharPrintUniform -> "char_print_uniform"
    CharAlpha -> "char_alpha"
    CharAlphaNumeric -> "char_alpha_numeric"
    CharWhitespace -> "char_whitespace"
    CharPrint -> "char_print"
  }
}

fn qcheck_function_to_attribute(
  qcheck_function: QcheckFunction,
) -> attribute.Attribute(_) {
  qcheck_function |> qcheck_function_to_string |> attribute.value
}

fn qcheck_function_from_string(
  function_name: String,
) -> Result(QcheckFunction, String) {
  case function_name {
    "int_uniform" -> Ok(IntUniform)
    "int_uniform_inclusive" -> Ok(IntUniformInclusive)
    "int_small_positive_or_zero" -> Ok(IntSmallPositiveOrZero)
    "int_small_strictly_positive" -> Ok(IntSmallStrictlyPositive)
    "float" -> Ok(Float)
    "float_uniform_inclusive" -> Ok(FloatUniformInclusive)
    "char" -> Ok(Char)
    "char_uniform" -> Ok(CharUniform)
    "char_uniform_inclusive" -> Ok(CharUniformInclusive)
    "char_utf_codepoint" -> Ok(CharUtfCodepoint)
    "char_uppercase" -> Ok(CharUppercase)
    "char_lowercase" -> Ok(CharLowercase)
    "char_digit" -> Ok(CharDigit)
    "char_print_uniform" -> Ok(CharPrintUniform)
    "char_alpha" -> Ok(CharAlpha)
    "char_alpha_numeric" -> Ok(CharAlphaNumeric)
    "char_whitespace" -> Ok(CharWhitespace)
    "char_print" -> Ok(CharPrint)
    _ -> Error("bad function name")
  }
}

fn init(_flags: _) -> #(Model, effect.Effect(Msg)) {
  #(default_model(), effect.from(fn(dispatch) { dispatch(EmbedPlot) }))
}

// MARK: Update

pub type Msg {
  UserChangedFunction(String)
  UserUpdatedIntRangeLow(Result(Int, String))
  UserUpdatedIntRangeHigh(Result(Int, String))
  EmbedPlot
  SetErrorMessage(String)
  DismissError
}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    UserChangedFunction(function) -> {
      case qcheck_function_from_string(function) {
        Ok(function) -> #(Model(..model, function:), effect.none())
        Error(message) -> #(
          Model(..model, error_message: option.Some(message)),
          effect.none(),
        )
      }
    }
    EmbedPlot -> {
      #(model, effect.from(fn(_) { model |> generate_histogram |> embed_plot }))
    }
    SetErrorMessage(error_message) -> #(
      Model(..model, error_message: option.Some(error_message)),
      effect.none(),
    )
    DismissError -> #(Model(..model, error_message: option.None), effect.none())
    UserUpdatedIntRangeLow(Ok(int_range_low)) -> #(
      Model(..model, int_range_low:),
      effect.none(),
    )
    UserUpdatedIntRangeHigh(Ok(int_range_high)) -> #(
      Model(..model, int_range_high:),
      effect.none(),
    )
    UserUpdatedIntRangeLow(Error(error_message)) -> #(
      Model(
        ..model,
        int_range_low: default_int_range_low,
        error_message: option.Some(error_message),
      ),
      effect.none(),
    )
    UserUpdatedIntRangeHigh(Error(error_message)) -> #(
      Model(
        ..model,
        int_range_high: default_int_range_high,
        error_message: option.Some(error_message),
      ),
      effect.none(),
    )
  }
}

// MARK: View

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([], [
    maybe_show_error(model.error_message),
    // Options
    html.div([], [
      html.h2([], [element.text("Options")]),
      // Select function
      html.select(
        [event.on_input(UserChangedFunction)],
        qcheck_function_html_options(model.function),
      ),
      html.br([]),
      maybe_function_options(model),
      html.br([]),
      maybe_generate_button(model.error_message),
    ]),
    // Plot
    html.div([], [
      html.h2([], [element.text("Data")]),
      html.div([attribute.id("plot")], [element.text("Click 'Generate'")]),
    ]),
  ])
}

fn maybe_show_error(error_message) {
  case error_message {
    option.None -> element.none()
    option.Some(error_message) -> {
      html.div(
        [
          attribute.id(id_error_message),
          attribute.style([
            #("background", "#fee2e2"),
            #("padding", "1rem"),
            #("margin", "1rem 0"),
            #("border-radius", "0.375rem"),
          ]),
        ],
        [
          html.span([], [element.text(error_message)]),
          html.button(
            [
              event.on_click(DismissError),
              attribute.style([#("margin-left", "1rem")]),
            ],
            [element.text("x")],
          ),
        ],
      )
    }
  }
}

fn maybe_function_options(model: Model) {
  case model.function {
    // TODO: make a float input box for the float functions.
    IntUniformInclusive | FloatUniformInclusive -> {
      html.div([], [
        html.label([], [
          html.label([], [
            html.text("High"),
            html.input([
              attribute.name("range-high"),
              attribute.type_("number"),
              attribute.property("value", model.int_range_high),
              event.on_input(parse_int_range_high(_, low: model.int_range_low)),
            ]),
          ]),
          html.br([]),
          html.text("Low"),
          html.input([
            attribute.name("range-low"),
            attribute.type_("number"),
            attribute.property("value", model.int_range_low),
            event.on_input(parse_int_range_low(_, high: model.int_range_high)),
          ]),
        ]),
      ])
    }
    _ -> element.none()
  }
}

fn maybe_generate_button(error_message) {
  case error_message {
    option.None ->
      html.button([event.on_click(EmbedPlot)], [element.text("Generate")])
    option.Some(_) -> element.none()
  }
}

// TODO: if user types `-` as if to start a negative number, it will give an
// error because that doesn't parse.  It's a bit confusing.

pub fn parse_int_range_low(new_low, high high) {
  case int.parse(new_low) {
    Ok(low) if low >= high ->
      UserUpdatedIntRangeLow(Error("bad int range: low >= high"))
    Ok(low) if low < min_int ->
      UserUpdatedIntRangeLow(Error(
        "bad int range: low < " <> int.to_string(min_int),
      ))
    Ok(low) if low > max_int ->
      UserUpdatedIntRangeLow(Error(
        "bad int range: low > " <> int.to_string(max_int),
      ))
    Ok(low) -> UserUpdatedIntRangeLow(Ok(low))
    Error(Nil) -> UserUpdatedIntRangeLow(Error("bad int range low"))
  }
}

pub fn parse_int_range_high(new_high, low low) {
  case int.parse(new_high) {
    Ok(high) if high <= low ->
      UserUpdatedIntRangeHigh(Error("bad int range: high <= low"))
    Ok(high) if high < min_int ->
      UserUpdatedIntRangeHigh(Error(
        "bad int range: high < " <> int.to_string(min_int),
      ))
    Ok(high) if high > max_int ->
      UserUpdatedIntRangeHigh(Error(
        "bad int range: high > " <> int.to_string(max_int),
      ))
    Ok(high) -> UserUpdatedIntRangeHigh(Ok(high))
    Error(Nil) -> UserUpdatedIntRangeHigh(Error("bad int range high"))
  }
}

// MARK: Plots

// This is the vega-lite spec for histogram.
fn histogram(from entries, of inner_type, bin bin) {
  json.object([
    #("$schema", json.string("https://vega.github.io/schema/vega-lite/v5.json")),
    #(
      "data",
      json.object([#("values", json.array(from: entries, of: inner_type))]),
    ),
    #("mark", json.string("bar")),
    #(
      "encoding",
      json.object([
        #(
          "y",
          json.object(case bin {
            True -> [#("bin", json.bool(True)), #("field", json.string("data"))]
            False -> [#("field", json.string("data"))]
          }),
        ),
        #("x", json.object([#("aggregate", json.string("count"))])),
      ]),
    ),
  ])
}

@external(javascript, "./qcheck_viewer_ffi.mjs", "vega_embed")
fn vega_embed(id: String, vega_lite_spec: json.Json) -> Nil

fn embed_plot(vega_lite_spec: json.Json) -> Nil {
  vega_embed("#plot", vega_lite_spec)
}

fn generate_histogram(model: Model) -> json.Json {
  case model.function {
    IntUniform -> gen_histogram(qcheck.int_uniform(), of: json.int, bin: True)
    IntUniformInclusive ->
      gen_histogram(
        qcheck.int_uniform_inclusive(model.int_range_low, model.int_range_high),
        of: json.int,
        bin: True,
      )
    IntSmallPositiveOrZero ->
      gen_histogram(
        qcheck.int_small_positive_or_zero(),
        of: json.int,
        bin: False,
      )
    IntSmallStrictlyPositive ->
      gen_histogram(
        qcheck.int_small_strictly_positive(),
        of: json.int,
        bin: False,
      )
    Float -> gen_histogram(qcheck.float(), of: json.float, bin: True)
    FloatUniformInclusive ->
      gen_histogram(
        qcheck.float_uniform_inclusive(
          int.to_float(model.int_range_low),
          int.to_float(model.int_range_high),
        ),
        of: json.float,
        bin: True,
      )

    Char -> gen_histogram(qcheck.char(), of: json.string, bin: False)
    CharUniform ->
      gen_histogram(qcheck.char_uniform(), of: json.string, bin: False)
    CharUniformInclusive ->
      gen_histogram(
        qcheck.char_uniform_inclusive(model.int_range_low, model.int_range_high),
        of: json.string,
        bin: False,
      )
    CharUtfCodepoint ->
      gen_histogram(
        qcheck.char_utf_codepoint()
          |> qcheck.map(fn(char) {
            let assert [cp] = string.to_utf_codepoints(char)
            string.utf_codepoint_to_int(cp)
          }),
        of: json.int,
        bin: True,
      )
    CharUppercase ->
      gen_histogram(qcheck.char_uppercase(), of: json.string, bin: False)
    CharLowercase ->
      gen_histogram(qcheck.char_lowercase(), of: json.string, bin: False)
    CharDigit -> gen_histogram(qcheck.char_digit(), of: json.string, bin: False)
    CharPrintUniform ->
      gen_histogram(qcheck.char_print_uniform(), of: json.string, bin: False)
    CharAlpha -> gen_histogram(qcheck.char_alpha(), of: json.string, bin: False)
    CharAlphaNumeric ->
      gen_histogram(qcheck.char_alpha_numeric(), of: json.string, bin: False)
    CharWhitespace ->
      gen_histogram(qcheck.char_whitespace(), of: json.string, bin: False)
    CharPrint -> gen_histogram(qcheck.char_print(), of: json.string, bin: False)
  }
}

fn gen_histogram(generator, of to_json, bin bin) {
  gen(qcheck.default_config() |> qcheck.with_test_count(10_000), generator)
  |> histogram(of: to_json, bin:)
}

fn gen(config: qcheck.Config, generator: qcheck.Generator(a)) -> List(a) {
  do_gen(config, generator, [], 0)
}

fn do_gen(
  config: qcheck.Config,
  generator: qcheck.Generator(a),
  acc: List(a),
  k: Int,
) -> List(a) {
  case k > config.test_count {
    True -> acc
    False -> {
      let qcheck.Generator(generate) = generator
      let #(tree, seed) = generate(config.random_seed)
      let qcheck.Tree(value, _shrinks) = tree
      do_gen(
        qcheck.with_random_seed(config, seed),
        generator,
        [value, ..acc],
        k + 1,
      )
    }
  }
}
