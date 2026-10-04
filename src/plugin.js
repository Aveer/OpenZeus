import path from "node:path"
import { fileURLToPath } from "node:url"
import { define } from "@opencode-ai/plugin/v2/promise"

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const skillRoot = path.join(root, "skills")

export default define({
  id: "openzeus",

  async setup(ctx) {
    await ctx.skill.transform((draft) => {
      draft.source({
        type: "directory",
        path: skillRoot,
      })
    })
  },
})
