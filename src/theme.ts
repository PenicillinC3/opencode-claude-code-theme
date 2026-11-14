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
      neutral: "#F8F8F6",
      ink: "#121212",
      primary: "#D97757",
      success: "#788C5D",
      warning: "#B98A4B",
      error: "#C6613F",
      info: "#6A9BCC",
    },
    // The palette derivation gives the window chrome (the vertical tab sidebar)
    // a darker step than the session panel. Both use one surface so the sidebar
    // does not read as a separate sheet.
    v2Overrides: {
      "v2-background-bg-base": "#FCFCFB",
      "v2-background-bg-deep": "#FCFCFB",
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
  },
}
