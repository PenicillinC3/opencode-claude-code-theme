// Claude-Code palette for the OpenCode Desktop theme picker.
//
// The desktop theme format starts each mode from a seven-color palette:
// neutral (surface), ink (foreground), primary (clay accent), and the four
// feedback hues. The host derives every semantic token from these seeds.
//
// Both variants stay inside the warm Claude family. There is no cool SaaS
// blue: info uses Claude's sky tone, success uses cactus, warnings are kraft
// amber, and errors are the deeper clay red.

export const claudeCode = {
  $schema: "https://opencode.ai/desktop-theme.json",
  name: "Claude-Code",
  id: "claude-code",
  light: {
    palette: {
      neutral: "#F7F6F2",
      ink: "#1F1E1D",
      primary: "#D97757",
      success: "#788C5D",
      warning: "#B98A4B",
      error: "#C6613F",
      info: "#6A9BCC",
    },
    // Claude's light window is two surfaces: a warm grey rail behind the tab
    // sidebar and its chrome, and near-white paper for the session itself. The
    // palette derivation lands both on the same tone, so the surface tokens are
    // pinned here. Text is pinned too: the derived foreground runs darker than
    // the seed, and Claude's light ink is a soft warm black, not pure black.
    overrides: {
      "background-base": "#FBFBF9",
      "text-base": "#1F1E1D",
      "text-weak": "#5C5B56",
      "text-weaker": "#8C8A83",
      "text-strong": "#171614",
      "text-stronger": "#171614",
    },
    v2Overrides: {
      "v2-background-bg-base": "#FBFBF9",
      "v2-background-bg-deep": "#F0EFEA",
      "v2-text-text-base": "#1F1E1D",
      "v2-text-text-muted": "#5C5B56",
      "v2-text-text-faint": "#8C8A83",
    },
  },
  dark: {
    palette: {
      neutral: "#262624",
      ink: "#FAF9F5",
      primary: "#D97757",
      success: "#9DB884",
      warning: "#D8B06A",
      error: "#E08A72",
      info: "#8AB4D8",
    },
    // Dark mode reads in one warm grey. The derived ramp would give body copy,
    // labels, captions and timestamps four different tones, so both token sets
    // are pinned to the same value. Links, code highlighting and the text that
    // sits on a filled button keep their own colors, since they carry meaning
    // rather than hierarchy.
    overrides: {
      "text-base": "#B0AEA5",
      "text-weak": "#B0AEA5",
      "text-weaker": "#B0AEA5",
      "text-strong": "#B0AEA5",
      "text-stronger": "#B0AEA5",
    },
    v2Overrides: {
      "v2-text-text-base": "#B0AEA5",
      "v2-text-text-muted": "#B0AEA5",
      "v2-text-text-faint": "#B0AEA5",
      "v2-text-text-weak": "#B0AEA5",
      "v2-text-text-subtle": "#B0AEA5",
    },
  },
}
