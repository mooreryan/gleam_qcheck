# qcheck_viewer

`cheerio` is needed for the tests.

```
npm install --save-dev cheerio
```

You will also need to add

```
  "type": "module"
```

to the `./node_modules/vega-embed/package.json` if you want to run the tests.

## Vega

Using vegaEmbed is very heavy. It adds ~800kb to the bundle size. Would be nice to find an alternative.
