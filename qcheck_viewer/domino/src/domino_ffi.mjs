import * as cheerio from "cheerio";

export function from_string(string) {
  return cheerio.load(string);
}

export function select(cheerio_api, selector) {
  return cheerio_api(selector);
}

export function text(cheerio_object) {
  return cheerio_object.text();
}

export function attr(cheerio_object, attr_name) {
  return cheerio_object.attr(attr_name);
}

export function attrs(cheerio_object) {
  return cheerio_object.attr();
}

export function length(cheerio_object) {
  return cheerio_object.length;
}
