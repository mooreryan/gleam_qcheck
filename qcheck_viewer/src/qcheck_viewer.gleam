import gleam/int
import gleam/json
import gleam/option
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import qcheck

const default_int_range_low: Int = -100

const default_int_range_high: Int = 100

const max_int: Int = 2_147_483_647

const min_int: Int = -2_147_483_648

pub const id_error_message = "error-message"

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MARK: Model

@internal
pub type Model {
  Model(
    function: QcheckFunction,
    int_range_low: Int,
    int_range_high: Int,
    error_message: option.Option(String),
  )
}

@internal
pub fn default_model() -> Model {
  Model(
    function: IntUniformInclusive,
    int_range_low: default_int_range_low,
    int_range_high: default_int_range_high,
    error_message: option.None,
  )
}

@internal
pub type QcheckFunction {
  IntUniform
  IntUniformInclusive
  IntSmallPositiveOrZero
  IntSmallStrictlyPositive
  Float
  Char
}

fn qcheck_function_html_options(
  model_function: QcheckFunction,
) -> List(element.Element(_)) {
  [
    qcheck_function_to_html_option(
      IntSmallPositiveOrZero,
      selected: model_function == IntSmallPositiveOrZero,
    ),
    qcheck_function_to_html_option(
      IntSmallStrictlyPositive,
      selected: model_function == IntSmallStrictlyPositive,
    ),
    qcheck_function_to_html_option(
      IntUniform,
      selected: model_function == IntUniform,
    ),
    qcheck_function_to_html_option(
      IntUniformInclusive,
      selected: model_function == IntUniformInclusive,
    ),
    qcheck_function_to_html_option(Float, selected: model_function == Float),
    qcheck_function_to_html_option(Char, selected: model_function == Char),
  ]
}

fn qcheck_function_to_html_option(
  qcheck_function: QcheckFunction,
  selected selected: Bool,
) -> element.Element(_) {
  html.option(
    [
      qcheck_function_to_attribute(qcheck_function),
      attribute.selected(selected),
    ],
    qcheck_function_to_string(qcheck_function),
  )
}

fn qcheck_function_to_string(qcheck_function: QcheckFunction) -> String {
  case qcheck_function {
    IntUniform -> "int_uniform"
    IntUniformInclusive -> "int_uniform_inclusive"
    IntSmallStrictlyPositive -> "int_small_strictly_positive"
    IntSmallPositiveOrZero -> "int_small_positive_or_zero"
    Float -> "float"
    Char -> "char"
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
    "char" -> Ok(Char)
    _ -> Error("bad function name")
  }
}

fn init(_flags: _) -> #(Model, effect.Effect(Msg)) {
  #(default_model(), effect.from(fn(dispatch) { dispatch(EmbedPlot) }))
}

// MARK: Update

@internal
pub type Msg {
  ChangeFunction(String)
  EmbedPlot
  SetErrorMessage(String)
  DismissError
  UpdateIntRangeLow(Int)
  UpdateIntRangeLowError(String)
  UpdateIntRangeHigh(Int)
  UpdateIntRangeHighError(String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    ChangeFunction(function) -> {
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
    UpdateIntRangeLow(int_range_low) -> #(
      Model(..model, int_range_low:),
      effect.none(),
    )
    UpdateIntRangeHigh(int_range_high) -> #(
      Model(..model, int_range_high:),
      effect.none(),
    )
    UpdateIntRangeLowError(error_message) -> #(
      Model(
        ..model,
        int_range_low: default_int_range_low,
        error_message: option.Some(error_message),
      ),
      effect.none(),
    )
    UpdateIntRangeHighError(error_message) -> #(
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

@internal
pub fn view(model: Model) -> element.Element(Msg) {
  html.div([], [
    maybe_show_error(model.error_message),
    // Options
    html.div([], [
      html.h2([], [element.text("Options")]),
      // Select function
      html.select(
        [event.on_input(ChangeFunction)],
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
    IntUniformInclusive -> {
      html.div([], [
        html.label([], [
          html.label([], [
            html.text("High"),
            html.input([
              attribute.name("high"),
              attribute.type_("number"),
              attribute.property("value", model.int_range_high),
              event.on_input(parse_int_range_high(_, low: model.int_range_low)),
            ]),
          ]),
          html.br([]),
          html.text("Low"),
          html.input([
            attribute.name("low"),
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
// error because that doesn't parse.

fn parse_int_range_low(new_low, high high) {
  case int.parse(new_low) {
    Ok(low) if low >= high ->
      UpdateIntRangeLowError("bad int range: low >= high")
    Ok(low) if low < min_int ->
      UpdateIntRangeLowError("bad int range: low < " <> int.to_string(min_int))
    Ok(low) if low > max_int ->
      UpdateIntRangeLowError("bad int range: low > " <> int.to_string(max_int))
    Ok(low) -> UpdateIntRangeLow(low)
    Error(Nil) -> UpdateIntRangeLowError("bad int range low")
  }
}

fn parse_int_range_high(new_high, low low) {
  case int.parse(new_high) {
    Ok(high) if high <= low ->
      UpdateIntRangeHighError("bad int range: high <= low")
    Ok(high) if high < min_int ->
      UpdateIntRangeHighError(
        "bad int range: high < " <> int.to_string(min_int),
      )
    Ok(high) if high > max_int ->
      UpdateIntRangeHighError(
        "bad int range: high > " <> int.to_string(max_int),
      )
    Ok(high) -> UpdateIntRangeHigh(high)
    Error(Nil) -> UpdateIntRangeHighError("bad int range high")
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
  let default_test_count = 10_000

  case model.function {
    IntUniform ->
      gen(
        qcheck.default_config() |> qcheck.with_test_count(default_test_count),
        qcheck.int_uniform(),
      )
      |> histogram(of: json.int, bin: True)
    IntUniformInclusive ->
      gen(
        qcheck.default_config() |> qcheck.with_test_count(default_test_count),
        qcheck.int_uniform_inclusive(model.int_range_low, model.int_range_high),
      )
      |> histogram(of: json.int, bin: True)
    IntSmallPositiveOrZero ->
      gen(
        qcheck.default_config() |> qcheck.with_test_count(default_test_count),
        qcheck.int_small_positive_or_zero(),
      )
      |> histogram(of: json.int, bin: False)
    IntSmallStrictlyPositive ->
      gen(
        qcheck.default_config() |> qcheck.with_test_count(default_test_count),
        qcheck.int_small_strictly_positive(),
      )
      |> histogram(of: json.int, bin: False)
    Float ->
      gen(
        qcheck.default_config() |> qcheck.with_test_count(default_test_count),
        qcheck.float(),
      )
      |> histogram(of: json.float, bin: True)
    Char ->
      gen(
        qcheck.default_config() |> qcheck.with_test_count(default_test_count),
        qcheck.char(),
      )
      |> histogram(of: json.string, bin: False)
  }
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
