import { Plugin, Style, Theme } from "@opencode/plugin/gui"
import { fontsCss } from "./fonts.generated"
import { claudeCode } from "./theme"

export default Plugin.define({
  setup(ctx) {
    // Add "Claude-Code" to Settings > Appearance > Theme.
    ctx.add(Theme, claudeCode)

    // Bind the installed Anthropic families, embed the Source Han families, and
    // apply them app-wide.
    ctx.add(Style, fontsCss)
  },
})
