//// Shrinking helper functions
////
//// This module contains helper functions that can be used to build custom generators (not by composing other generators).
////
//// They are mostly inteded for internal use or "advanced" manual construction
//// of generators.  In typical usage, you will probably not need to interact
//// with these functions much, if at all.  As such, they are currently mostly
//// undocumented.
////
//// In fact, if you are using these functions a lot, file a issue on GitHub
//// and let me know if there are any generator combinators that you're missing.
////

import gleam/yielder.{type Yielder}

fn float_half_difference(x: Float, y: Float) -> Float {
  { x /. 2.0 } -. { y /. 2.0 }
}

fn int_half_difference(x: Int, y: Int) -> Int {
  { x / 2 } - { y / 2 }
}

fn int_shrink_step(
  x x: Int,
  current_shrink current_shrink: Int,
) -> yielder.Step(Int, Int) {
  case x == current_shrink {
    True -> yielder.Done
    False -> {
      let half_difference = int_half_difference(x, current_shrink)

      case half_difference == 0 {
        True -> {
          yielder.Next(current_shrink, x)
        }
        False -> {
          yielder.Next(current_shrink, current_shrink + half_difference)
        }
      }
    }
  }
}

fn float_shrink_step(
  x x: Float,
  current_shrink current_shrink: Float,
) -> yielder.Step(Float, Float) {
  case x == current_shrink {
    True -> yielder.Done
    False -> {
      let half_difference = float_half_difference(x, current_shrink)

      case half_difference == 0.0 {
        True -> {
          yielder.Next(current_shrink, x)
        }
        False -> {
          yielder.Next(current_shrink, current_shrink +. half_difference)
        }
      }
    }
  }
}

pub fn int_towards(
  destination destination: Int,
) -> fn(Int) -> yielder.Yielder(Int) {
  fn(x) {
    yielder.unfold(destination, fn(current_shrink) {
      int_shrink_step(x: x, current_shrink: current_shrink)
    })
  }
}

pub fn float_towards(
  destination destination: Float,
) -> fn(Float) -> yielder.Yielder(Float) {
  fn(x) {
    yielder.unfold(destination, fn(current_shrink) {
      float_shrink_step(x: x, current_shrink: current_shrink)
    })
    // (Arbitrarily) Limit to the first 15 elements as dividing a `Float` by 2
    // doesn't converge quickly towards the destination.
    |> yielder.take(15)
  }
}

pub fn int_towards_zero() -> fn(Int) -> yielder.Yielder(Int) {
  int_towards(destination: 0)
}

pub fn float_towards_zero() -> fn(Float) -> yielder.Yielder(Float) {
  float_towards(destination: 0.0)
}

/// The `atomic` shrinker treats types as atomic, and never attempts to produce
/// smaller values.
pub fn atomic() -> fn(a) -> Yielder(a) {
  fn(_) { yielder.empty() }
}
