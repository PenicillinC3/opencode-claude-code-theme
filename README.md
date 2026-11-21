# Claude-Code theme for OpenCode Desktop

**English** | [简体中文](README.zh-CN.md)

A local OpenCode Desktop plugin that adds a **Claude-Code** theme and Claude-style
typography to OpenCode Desktop.

- Warm paper palette with clay `#D97757` as the only accent, in light and dark
  variants.
- Light mode follows Claude's window: a warm grey rail (`#F0EFEA`) behind the tab
  sidebar and its chrome, near-white paper (`#FBFBF9`) for the session, and warm
  black text.
- Dark mode reads in one warm grey: body copy, labels, captions and timestamps
  all use `#B0AEA5`. Links, code highlighting and the text on filled buttons
  keep their own colors.
- Anthropic Sans for UI text and Anthropic Serif for Markdown headings, using
  the copies installed on your machine. If they are missing, the theme falls
  back to the embedded Source Han Latin glyphs and then the platform fonts.
- One weight everywhere, like Claude's client: regular Latin and Source Han 450,
  with no bold variants and synthetic bold disabled.
- Chinese text uses **Source Han Sans CN** and **Source Han Serif SC**, embedded
  in the plugin. No system CJK font installation is required.
- Claude-style session chrome: the header names the project without a tile, the
  sidebar lists sessions without project tiles, the composer keeps the model
  name and effort at the right, next to a quiet borderless send arrow, and a new
  session opens on a serif greeting instead of the product wordmark.

The repository ships a prebuilt `dist/gui-experimental.cjs`.
Building is only needed if you change the source.

## Quick start (Windows)

[Download `install.bat`](https://github.com/PenicillinC3/opencode-claude-code-theme/raw/main/install.bat)
and double-click it.

- Copies the theme to `%LOCALAPPDATA%\opencode-claude-code-theme`.
- Adds it to `%USERPROFILE%\.config\opencode\opencode.jsonc`, keeping your
  comments and other plugins, after a timestamped backup.
- Needs no Node.js, npm, or build step.

Restart OpenCode Desktop, then choose **Claude-Code** in
**Settings › Appearance › Theme**. If you already cloned the repository, run
`install.bat` from that folder instead; it installs that copy.

## Requirements

- OpenCode Desktop 2.2.6 or newer (the version with desktop GUI plugins).
- Windows 10 or 11 for the one-click installer.
- Anthropic Sans and Anthropic Serif installed for the intended Latin typography
  (optional; see [Fonts and coverage](#fonts-and-coverage)).
- Node.js 20+ and npm, only to build from source. Installing the theme needs
  neither.

## Install

### Windows: one-click installer (recommended)

1. Download [`install.bat`](https://github.com/PenicillinC3/opencode-claude-code-theme/raw/main/install.bat)
   and double-click it. If you already have the repository (cloned or unzipped),
   run `install.bat` from that folder instead; it installs that copy.
2. The script downloads the latest theme (about 10 MB), copies it to
   `%LOCALAPPDATA%\opencode-claude-code-theme`, and adds the plugin to
   `%USERPROFILE%\.config\opencode\opencode.jsonc`. It keeps your comments,
   writes a timestamped backup of the config first, and leaves other plugins
   alone. No Node.js, npm, or build step is involved.
3. Restart OpenCode Desktop, then open **Settings › Appearance › Theme** and
   choose **Claude-Code**.

Running `install.bat` again updates the installed copy and keeps a single config
entry. Run [`uninstall.bat`](uninstall.bat) to remove both.

If Windows asks before running the file, choose **More info › Run anyway**: the
scripts are plain text and can be read in this repository.

### Manual install (any platform)

The repository can be cloned or extracted anywhere. Register the folder that
contains `package.json`; the plugin does not need to sit at a fixed path, and it
needs no `npm install` at runtime.

#### 1. Get the plugin

```bash
git clone https://github.com/PenicillinC3/opencode-claude-code-theme.git
```

Replace `opencode-claude-code-theme` with your repository name if you renamed or
forked it. Without git, download the repository as a ZIP and extract it anywhere.

#### 2. Register the plugin

Open the **global** OpenCode config, creating it if necessary:

- Windows: `%USERPROFILE%\.config\opencode\opencode.jsonc`
- macOS / Linux: `~/.config/opencode/opencode.jsonc`

Keep any existing keys and add the plugin as an **absolute file URL** pointing
at the repository folder:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": ["file:///absolute/path/to/opencode-claude-code-theme"]
}
```

Examples:

```jsonc
// Windows
"plugins": ["file:///C:/Users/you/repos/opencode-claude-code-theme"]

// macOS
"plugins": ["file:///Users/you/repos/opencode-claude-code-theme"]

// Linux
"plugins": ["file:///home/you/repos/opencode-claude-code-theme"]
```

Notes:

- Use forward slashes, even on Windows.
- `~` is not expanded inside a `file://` URL; write the absolute path.
- If the path contains spaces, percent-encode them (`%20`) or move the repository
  to a path without spaces.
- The repository folder must contain `package.json`, `src/` and `dist/` after
  installing.

#### 3. Enable the theme

1. Restart OpenCode Desktop. Config changes are watched, but local plugin
   bundles can require a restart.
2. Open **Settings › Extensions › Plugins** and confirm
   `opencode-claude-code-theme` is listed. Use **Reload** if it was just added
   or previously failed.
3. Open **Settings › Appearance › Theme** and choose **Claude-Code**.

## Update

With the installer, run `install.bat` again.

From a checkout, run `git pull`, then reload the plugin or restart the app. Run
`npm run build` as well if you build the bundle locally.

## Uninstall

With the installer, run [`uninstall.bat`](uninstall.bat). It removes the entry
from the `plugins` array and deletes
`%LOCALAPPDATA%\opencode-claude-code-theme`.

By hand, remove the entry from the `plugins` array and reload. To hide the
plugin without removing the entry, prefix its id with `-`. Deleting the
repository folder is safe once the entry is gone.

## Build from source

```bash
cd opencode-claude-code-theme
npm install
npm run typecheck
npm run build
npm run smoke
```

`npm run build` regenerates `src/fonts.generated.ts` (local Anthropic faces plus
the embedded Chinese subsets) and writes `dist/gui-experimental.cjs` (about
4.65 MB, 3.5 MB gzipped).

### Rebuilding the Chinese subsets

Only needed after changing `assets/gb2312.txt` or the vertical compression
setting:

```bash
python -m pip install fonttools brotli
npm run subset
npm run build
```

The original Source Han variable fonts are not committed. To rebuild, place them
in a `source/` folder next to the repository (the subset script looks for
`../source/`):

- `../source/SourceHanSansCN-VF.otf`
- `../source/SourceHanSerifSC-VF.otf.ttf`

They are available from the Adobe
[Source Han Sans](https://github.com/adobe-fonts/source-han-sans/releases) and
[Source Han Serif](https://github.com/adobe-fonts/source-han-serif/releases)
releases.

The generated WOFF2 files in `assets/fonts/` are committed, so a normal install
or build does not need the variable fonts.

## What it changes

The plugin registers two things through the experimental desktop plugin API:

- a `Theme` named `Claude-Code` (`claude-code`);
- a `Style` sheet with the `@font-face` rules and typography overrides.

The app resolves fonts through `--font-family-sans` and `--font-family-mono`,
then derives `--font-family-text`, `--v2-font-family-sans` and
`--v2-font-family-code` from them. The plugin overrides those variables on
`html:root` so they win regardless of stylesheet order. Markdown `h1`–`h3` use
Anthropic Serif (Source Han Serif SC for Chinese); reasoning output stays sans.

The composer is lifted from the app's 13 px to the 14 px body size, with its
20 px line height kept, so the input reads at the same size and compression as
the messages above it.

Claude's sidebar session list is text-only: rows carry no project tile. The
theme removes the tile and its 16 px slot, so session titles start at the list's
left edge instead of after an avatar column. Unread and activity markers stay at
the row's trailing edge. Session titles hold one quiet gray (`#3d3d3a`) on every
row, active or not, and the composer's placeholder line uses the same gray.

Claude's session header names the current project without a tile, so the project
avatar inside the session location card is hidden. The project name and
breadcrumb text remain. The larger avatar in the location menu is unaffected.

Claude groups the model name and reasoning effort at the right end of the
composer, just before the send arrow; the agent control stays at the left. The
submit control is a quiet borderless arrow rather than a framed button. It keeps
the native 28 px target and icon, a transparent fill, and a muted arrow. Hover
adds only a faint fill. The working stop square and loader keep the same quiet
treatment.

Claude opens a new session with a greeting rather than a logo: the animated
OpenCode wordmark and its pin board are hidden, and a line of `You're here!` in
Anthropic Serif takes their place. The wordmark box still reserves its height,
so the composer does not move. The new-session column is narrowed to 680 px,
matching Claude's single centered column of greeting, input, and project row. In
that row the project avatar tile is replaced by the app's folder outline, drawn
in the trigger's text color.

These chrome overrides target the OpenCode Desktop 2.2.x DOM. The theme, fonts,
and palette are stable, but a future app release may rename the elements behind
the sidebar, composer, or greeting selectors.

## Fonts and coverage

| Family                      | Role                 | Source                                      |
| --------------------------- | -------------------- | ------------------------------------------- |
| Anthropic Sans Text 400     | Interface text       | Installed: `Anthropic Sans Text`            |
| Anthropic Serif Display 400 | Markdown headings    | Installed: `Anthropic Serif Display`        |
| Anthropic Serif Display 300 | New-session greeting | Installed: `Anthropic Serif Display`        |
| Source Han Sans CN 450      | Chinese UI text      | Embedded from `SourceHanSansCN-VF.otf`      |
| Source Han Serif SC 450     | Chinese headings     | Embedded from `SourceHanSerifSC-VF.otf.ttf` |

The Anthropic families are not bundled. The theme binds them with `local()`, so
they are used only when the fonts are installed; otherwise the stack continues
to the embedded Source Han subsets and then the platform fonts.

### Where to get the fonts

The Anthropic fonts are proprietary and are not distributed with this
repository. The theme's `local()` rules look for the installed families
`Anthropic Sans Text` and `Anthropic Serif Display`. If you do not already have
the fonts from Anthropic, a third-party mirror carries copies:

- [matthieuhuguet/anthropic-fonts](https://github.com/matthieuhuguet/anthropic-fonts)
  mirrors variable TTF and WOFF2 builds. It is an unofficial third-party upload
  described as "personal use only, not my IP". Its files install as
  `AnthropicSans` and `AnthropicSerif`, which the theme's `local()` lookups do
  not match, so the embedded fallback fonts are used instead.

This link is provided for convenience only and is not affiliated with this
project. Check Anthropic's terms before downloading or using the fonts, and do
not redistribute the files.

The Chinese fonts are subset to GB2312: 7,402 code points covering common
Chinese, Latin, and punctuation. That keeps the bundle practical. Characters
outside the subset, and Japanese/Korean text, fall back to the platform CJK
fonts (`PingFang SC`, `Microsoft YaHei`, `Noto Sans CJK SC`, `SimSun`, etc.).

The Source Han glyphs are instanced at weight 450 and compressed by 7.5%
**vertically only** (horizontal advances and widths are unchanged). Source Han
Sans has long, thin vertical strokes that look taller than the Latin UI font at
13–16 px; the small vertical correction keeps mixed Chinese/English lines even.

Every family exposes one face only, declared across the full `100 900` weight
range with synthetic bold disabled. The Latin families are bound with `local()`
to the installed regular cut, so medium and bold text stays visually identical
to body text instead of switching to a heavier installed cut or a synthesized
bold. The new-session greeting is the one exception: it binds to the installed
light display cut, one step below the heading serif. If the light cut is
missing, it falls back to the regular display serif.

## Troubleshooting

**The theme is not listed.** Check that the config file is the global one for
your platform, that the `plugins` entry points at the repository folder
containing `package.json`, and that the plugin appears under
**Settings › Extensions › Plugins**. Restart the app after fixing the path.

**Latin text looks like the Chinese font.** The Anthropic fonts are not
installed, or the app cannot see them. Install Anthropic Sans Text and Anthropic
Serif Display (see [Where to get the fonts](#where-to-get-the-fonts)), then
restart OpenCode Desktop.

**The sidebar, composer, or greeting overrides stopped working.** The app
version probably changed the DOM. Check the app version against the requirements
and open an issue with the version number.

## Licensing

- **Theme and plugin code** are released under the MIT License. See
  [LICENSE](LICENSE).
- **Anthropic Sans and Anthropic Serif** are proprietary Anthropic fonts. This
  repository does not include them; the plugin uses the copies installed on the
  machine. Do not redistribute the font files.
- **Source Han Sans / Source Han Serif** are licensed under the SIL Open Font
  License 1.1 (<https://openfontlicense.org>). The embedded subsets keep the
  same license.

The MIT license covers the code and theme definitions, not the font files.

## Layout

```text
opencode-claude-code-theme/
  README.md
  README.zh-CN.md
  .gitattributes
  .gitignore
  LICENSE
  install.bat            one-click installer (Windows)
  install.ps1            installer logic; also handles -Uninstall
  uninstall.bat          one-click uninstaller (Windows)
  src/
    index.ts             server-side plugin entry
    gui.ts               desktop GUI entry (Theme + Style)
    theme.ts             Claude-Code palette
    fonts.generated.ts   generated: local @font-face rules + embedded CJK + CSS
  scripts/
    embed-fonts.mjs      builds the font CSS: local Anthropic faces + embedded CJK
    build-cjk-fonts.py   subsets, instances and vertically adjusts the CJK fonts
    subset-fonts.ps1     rebuilds the GB2312 WOFF2 subsets
    smoke-test.cjs       loads the built bundle and checks its registrations
  assets/
    fonts/               embedded CJK subsets
    gb2312.txt           subset code points
  dist/
    gui-experimental.cjs built desktop bundle
```

`source/` sits next to the repository and is not committed. It contains the
proprietary Anthropic font files and the large variable fonts, and is only
needed to rebuild the Chinese subsets.

The desktop GUI plugin API is experimental (`./gui-experimental`), so a future
app release may change the import or loader contract. The server entry and theme
format are stable plugin APIs.
