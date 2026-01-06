import { readFileSync } from "node:fs";
import { Result$Ok, Result$Error } from "../../gleam.mjs";

export function read_file(path) {
  try {
    return Result$Ok(readFileSync(path));
  } catch {
    return Result$Error(undefined);
  }
}
