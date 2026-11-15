// Server-side entry.
//
// The theme itself is contributed by the desktop GUI entry (./gui-experimental),
// so this entry only registers the plugin id. It deliberately has no imports:
// the plugin then loads from a fresh checkout without `npm install`, which keeps
// the Windows installer dependency-free.

export default {
  id: "claude-code-theme",
  setup() {},
}
