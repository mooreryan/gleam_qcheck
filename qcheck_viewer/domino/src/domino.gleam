import gleam/dynamic/decode

pub type Domino

pub type DominoApi

@external(javascript, "./domino_ffi.mjs", "from_string")
pub fn from_string(_input: String) -> DominoApi

/// WARNING: Do not call io.debug on the output of this function. It will cause
///   a stack overflow.
@external(javascript, "./domino_ffi.mjs", "select")
pub fn select(domino_api: DominoApi, selector: String) -> Domino

@external(javascript, "./domino_ffi.mjs", "text")
pub fn text(domino: Domino) -> String

/// Gets the attribute value for only the first element in the matched set.
@external(javascript, "./domino_ffi.mjs", "attr")
pub fn attr(domino: Domino, name: String) -> String

/// Gets the attribute value for only the first element in the matched set.
@external(javascript, "./domino_ffi.mjs", "attrs")
pub fn attrs(domino: Domino) -> decode.Dynamic

@external(javascript, "./domino_ffi.mjs", "length")
pub fn length(domino: Domino) -> Int
