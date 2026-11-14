const assert = require("node:assert")
const Module = require("node:module")

const additions = []
const stub = {
  Plugin: { define: (plugin) => plugin },
  Theme: { registry: "theme" },
  Style: { registry: "style" },
}

const load = Module._load
Module._load = function (request, parent, isMain) {
  if (request === "@opencode/plugin/gui") return stub
  return load.apply(this, arguments)
}

const bundle = require("../dist/gui-experimental.cjs")
const plugin = bundle.default

assert.ok(plugin, "bundle must default-export the plugin definition")
assert.equal(typeof plugin.setup, "function", "plugin must define a window setup")

const ctx = {
  add(registry, value) {
    additions.push({ registry, value })
  },
}

const cleanup = plugin.setup(ctx)

assert.equal(additions.length, 2, "setup must add exactly Theme and Style")
assert.equal(cleanup, undefined, "setup must not return a cleanup")

const theme = additions.find((item) => item.registry === stub.Theme).value
const css = additions.find((item) => item.registry === stub.Style).value

assert.equal(theme.name, "Claude-Code")
assert.equal(theme.id, "claude-code")
assert.equal(theme.light.palette.neutral, "#F8F8F6")
assert.equal(theme.light.palette.ink, "#121212")
assert.equal(theme.light.palette.primary, "#D97757")
assert.equal(theme.dark.palette.neutral, "#262624")
assert.equal(theme.dark.palette.ink, "#FAF9F5")

for (const family of ["Anthropic Sans", "Anthropic Serif", "Source Han Sans CN", "Source Han Serif SC"]) {
  assert.ok(css.includes(`font-family: "${family}"`), `css must define ${family}`)
}
for (const family of ["Anthropic Sans", "Source Han Sans CN"]) {
  assert.ok(css.includes(`"${family}"`), `body stack must include ${family}`)
}
assert.ok(css.includes("data:font/woff2;base64,"), "Chinese fonts must be embedded as woff2")
assert.ok(!css.includes("data:font/opentype;base64,"), "Anthropic fonts must not be embedded")
for (const local of [
  'local("Anthropic Sans Text Regular")',
  'local("Anthropic Serif Display Regular")',
  'local("Anthropic Serif Display Light")',
]) {
  assert.ok(css.includes(local), `css must resolve ${local}`)
}

// The desktop app resolves typography through --font-family-sans/-mono, so the
// plugin must override those variables (not just --font-sans/--font-mono).
assert.ok(css.includes("html:root"), "font overrides must outrank the app's :root rule")
for (const variable of [
  "--font-family-sans",
  "--font-family-text",
  "--font-family-mono",
  "--v2-font-family-sans",
  "--v2-font-family-code",
]) {
  assert.ok(css.includes(`${variable}: var(`), `css must override ${variable}`)
}
assert.ok(
  css.includes('[data-component="markdown"] :is(h1, h2, h3)'),
  "markdown headings must use the serif family",
)
assert.ok(
  css.includes('[data-component="reasoning-part"] [data-component="markdown"]'),
  "reasoning headings must stay sans",
)

console.log("smoke test ok")
console.log(`  theme: ${theme.name} (${theme.id})`)
console.log(`  style: ${(Buffer.byteLength(css) / 1024 / 1024).toFixed(2)} MiB`)
