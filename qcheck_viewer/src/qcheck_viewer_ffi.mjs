import vegaEmbed from "../../../../node_modules/vega-embed/build/vega-embed.module.js";

export function vega_embed(id, vega_lite_spec) {
  requestAnimationFrame(() => {
    vegaEmbed(id, vega_lite_spec);
  });
}
