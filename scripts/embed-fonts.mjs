// Builds the theme's font CSS.
//
// English: the theme uses the Anthropic Sans/Serif families installed on the
// user's machine. Each family is bound with local() to its regular face, so the
// interface keeps one visual weight; if the fonts are absent the stack falls
// back to the embedded Chinese subsets and then the platform fonts.
//
// Chinese: Source Han Sans CN + Source Han Serif SC, subset to GB2312 (7,400
// code points including Latin and punctuation) so the plugin stays a
// manageable size. The subsets are static 450 weight instances with the glyphs
// compressed 8% vertically, so Chinese text matches the optical height of the
// UI at small sizes. Characters outside the subset fall back to the platform
// CJK font declared in the CSS stack.
//
// Claude's interface uses one weight for everything, so each family exposes a
// single face across the whole 100-900 range. The faces are declared as that
// range and synthetic bold is disabled, which keeps every weight identical.
//
// Rebuild the Chinese subsets with scripts/subset-fonts.ps1, then run:
//   npm run fonts

import { readFile, writeFile } from "node:fs/promises"
import { fileURLToPath } from "node:url"
import path from "node:path"

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)))
const fontsDir = path.join(root, "assets", "fonts")
const outFile = path.join(root, "src", "fonts.generated.ts")

// Latin faces are not embedded: they resolve from the Anthropic fonts installed
// on the machine. A failed local() lookup makes the family unavailable, so the
// next family in the CSS stack takes over.
const localFonts = [
  {
    family: "Anthropic Sans",
    locals: ["Anthropic Sans Text Regular", "AnthropicSansText-Regular", "Anthropic Sans Text"],
  },
  {
    family: "Anthropic Serif",
    locals: ["Anthropic Serif Display Regular", "AnthropicSerifDisplay-Regular", "Anthropic Serif Display"],
  },
  {
    family: "Anthropic Serif Light",
    locals: ["Anthropic Serif Display Light", "AnthropicSerifDisplay-Light"],
  },
]

const fonts = [
  {
    family: "Source Han Sans CN",
    file: "SourceHanSansCN-450.woff2",
    weight: "100 900",
    format: "woff2",
  },
  {
    family: "Source Han Serif SC",
    file: "SourceHanSerifSC-450.woff2",
    weight: "100 900",
    format: "woff2",
  },
]

const face = ({ family, data, weight, format }) => `@font-face {
  font-family: "${family}";
  src: url("data:font/${format};base64,${data}") format("${format}");
  font-weight: ${weight};
  font-style: normal;
  font-display: swap;
}`

const localFace = ({ family, locals }) => `@font-face {
  font-family: "${family}";
  src: ${locals.map((name) => `local("${name}")`).join(",\n       ")};
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}`

const stack = {
  sans: [
    '"Anthropic Sans"',
    '"Anthropic Sans Text"',
    '"Source Han Sans CN"',
    "ui-sans-serif",
    "system-ui",
    "-apple-system",
    '"Segoe UI"',
    "Roboto",
    '"PingFang SC"',
    '"Hiragino Sans GB"',
    '"Noto Sans CJK SC"',
    '"Microsoft YaHei"',
    "sans-serif",
  ].join(", "),
  serif: [
    '"Anthropic Serif"',
    '"Anthropic Serif Display"',
    '"Source Han Serif SC"',
    "ui-serif",
    "Georgia",
    "Cambria",
    '"Times New Roman"',
    '"Songti SC"',
    '"STSong"',
    '"Noto Serif CJK SC"',
    "SimSun",
    "serif",
  ].join(", "),
  serifLight: [
    '"Anthropic Serif Light"',
    '"Anthropic Serif"',
    '"Anthropic Serif Display Light"',
    '"Anthropic Serif Display"',
    '"Source Han Serif SC"',
    "ui-serif",
    "Georgia",
    "Cambria",
    '"Times New Roman"',
    '"Songti SC"',
    '"STSong"',
    '"Noto Serif CJK SC"',
    "SimSun",
    "serif",
  ].join(", "),
  mono: [
    "ui-monospace",
    '"SFMono-Regular"',
    "Menlo",
    "Monaco",
    "Consolas",
    '"Cascadia Code"',
    '"Source Han Sans CN"',
    "monospace",
  ].join(", "),
}

const faces = localFonts.map(localFace)
for (const font of fonts) {
  const bytes = await readFile(path.join(fontsDir, font.file))
  faces.push(face({ ...font, data: bytes.toString("base64") }))
}

const css = `${faces.join("\n\n")}

/*
 * The desktop app resolves typography from --font-family-sans/-mono and
 * derives --font-family-text, --v2-font-family-sans and --v2-font-family-code
 * from them. Its theme engine writes --font-family-sans/-mono as inline styles
 * on <html>, which beat any regular author rule, so these declarations have to
 * be !important to win the cascade.
 */
:root,
:host {
  --claude-font-sans: ${stack.sans};
  --claude-font-serif: ${stack.serif};
  --claude-font-serif-light: ${stack.serifLight};
  --claude-font-mono: ${stack.mono};
}

html:root {
  --font-sans: var(--claude-font-sans) !important;
  --font-serif: var(--claude-font-serif) !important;
  --font-mono: var(--claude-font-mono) !important;

  --font-family-sans: var(--claude-font-sans) !important;
  --font-family-text: var(--claude-font-sans) !important;
  --font-family-mono: var(--claude-font-mono) !important;
  --v2-font-family-sans: var(--claude-font-sans) !important;
  --v2-font-family-code: var(--claude-font-mono) !important;

  /* One face per family: never fake a heavier weight. */
  font-synthesis-weight: none;
}

html,
body {
  font-family: var(--font-family-sans);
}

input,
textarea,
select,
button {
  font-family: inherit;
}

/* Serif headings inside rendered Markdown, but keep reasoning text sans. */
[data-component="markdown"] :is(h1, h2, h3) {
  font-family: var(--claude-font-serif);
  font-weight: 400;
  letter-spacing: -0.02em;
}

[data-component="reasoning-part"] [data-component="markdown"] :is(h1, h2, h3) {
  font-family: var(--font-family-sans);
  font-weight: inherit;
}

[data-component="markdown"] :is(h4, h5, h6) {
  font-family: var(--font-family-sans);
}

code,
pre,
kbd,
samp,
tt {
  font-family: var(--font-family-mono);
}

/*
 * Claude's sidebar session list is text-only: rows carry no project tile.
 * The tile and its 16 px slot are removed, so session titles start at the
 * list's left edge instead of after an avatar column. Unread and activity
 * markers sit at the row's trailing edge and are unaffected.
 */
[data-slot="vertical-tabs-sidebar"] [data-slot="project-avatar-slot"] {
  display: none !important;
}

/*
 * Session titles sit at one quiet gray whether or not the row is active, so
 * the list reads as navigation rather than a second column of content. The
 * same gray is used for the composer's placeholder line.
 */
[data-slot="vertical-tabs-sidebar"] [data-titlebar-tab-title],
[data-slot="vertical-tabs-sidebar"] [data-titlebar-tab-action] {
  color: #3d3d3a !important;
}

/*
 * Claude's session header names the location without a project tile, so the
 * header reads as a line of text rather than a directory card.
 */
[data-slot="session-location-trigger"] [data-component="project-avatar-v2"] {
  display: none !important;
}

/*
 * Claude's new-session project row leads with a folder outline, not a filled
 * avatar tile. The app already ships the folder glyph, so hide the avatar
 * surface and draw the same path as a mask in the trigger's text color.
 */
[data-component="new-session"]
  [data-action="prompt-project"]
  [data-component="project-avatar-v2"]
  [data-slot="project-avatar-surface"] {
  display: none !important;
}

[data-component="new-session"]
  [data-action="prompt-project"]
  [data-component="project-avatar-v2"]::before {
  content: "";
  display: block;
  width: 16px;
  height: 16px;
  background-color: currentColor;
  -webkit-mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M1.333 2V13.333H14.667V4H8.667L6.667 2H1.333Z' fill='none' stroke='black' stroke-width='1.5'/%3E%3C/svg%3E") center / contain no-repeat;
  mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M1.333 2V13.333H14.667V4H8.667L6.667 2H1.333Z' fill='none' stroke='black' stroke-width='1.5'/%3E%3C/svg%3E") center / contain no-repeat;
}

/*
 * Claude opens a new session with a line of display serif, not a product
 * wordmark. The wordmark's box keeps its height so the composer stays put,
 * while the animated logo and its pin-board canvases are hidden. The greeting
 * replaces them with a pseudo-element in Claude's ink, set in the light display
 * cut and with an ivory counterpart for dark mode.
 */
[data-component="new-session"] [data-component="new-session-wordmark"] {
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  min-height: 98px;
}

[data-component="new-session"] [data-component="new-session-wordmark"] [data-slot="wordmark-box"] {
  display: none !important;
}

[data-component="new-session"] [data-slot="new-session-pins"],
[data-component="new-session"] [data-slot="new-session-pins-popped"] {
  display: none !important;
}

[data-component="new-session"] [data-component="new-session-wordmark"]::after {
  content: "You're here!";
  font-family: var(--claude-font-serif-light);
  font-weight: 300;
  font-size: 40px;
  line-height: 1.1;
  letter-spacing: -0.02em;
  color: #141413;
}

[data-color-scheme="dark"] [data-component="new-session"] [data-component="new-session-wordmark"]::after {
  color: #faf9f5;
}

/*
 * Claude keeps the new-session column narrower than a working session's
 * composer, so the greeting, input, and project row read as one block.
 */
[data-component="new-session"] [class*="max-w-[880px]"] {
  max-width: 680px !important;
}

/*
 * Claude groups the model name and reasoning effort at the right end of the
 * composer, next to the send arrow. The agent control stays at the left; the
 * auto margin only moves the model chip and the variant chip after it.
 */
[data-slot="composer-controls"]
  :is(
    [data-component="tooltip-v2-trigger"]:has(> [data-action="composer-model"]),
    [data-action="composer-model"]
  ) {
  margin-inline-start: auto !important;
}

/*
 * The editor draws its hint as a positioned line beside the contenteditable
 * instead of a native ::placeholder, so it keeps its own color rule.
 */
[data-component="composer-editor"] + div {
  color: #3d3d3a !important;
}

/*
 * The composer's submit control is a quiet arrow in Claude, not a framed
 * button. Keep the native size, icon and hover fill; remove the outline and
 * the filled paint.
 */
[data-action="composer-submit"] {
  background-image: none !important;
  background-color: transparent !important;
  border: 0 !important;
  box-shadow: none !important;
  color: var(--v2-icon-icon-muted) !important;
  text-shadow: none !important;
  border-radius: 8px !important;
}

[data-action="composer-submit"]:hover:not(:disabled) {
  background-color: var(--v2-overlay-simple-overlay-hover) !important;
  color: var(--v2-text-text-base) !important;
}

[data-action="composer-submit"]:active:not(:disabled) {
  background-color: var(--v2-overlay-simple-overlay-pressed) !important;
}
`

await writeFile(
  outFile,
  `// This file is generated by scripts/embed-fonts.mjs. Do not edit.\nexport const fontsCss = ${JSON.stringify(css)}\n`,
  "utf8",
)

console.log(`wrote ${path.relative(root, outFile)} (${(Buffer.byteLength(css) / 1024 / 1024).toFixed(2)} MiB embedded)`)
