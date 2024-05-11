import { Ok, Error as GError } from "./gleam.mjs";

export function fail(msg) {
  throw new Error(msg)
}

export function rescue_error(f) {
  try {
    return new Ok(f());
  } catch (e) {
    if (e instanceof Error) {
      // `e` should be a string
      return new GError(e.message);
    } else {
      // rethrow the error
      throw e;
    }
  }
}
