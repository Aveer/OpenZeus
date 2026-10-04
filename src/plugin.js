import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"
import { Plugin } from "@opencode/plugin"

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const skillRoot = path.join(root, "skills")

function listData(result) {
  if (Array.isArray(result)) return result
  if (Array.isArray(result?.data)) return result.data
  return []
}

function pickAgent(item) {
  return {
    id: item?.id ?? item?.name ?? null,
    name: item?.name ?? null,
    description: item?.description ?? null,
    mode: item?.mode ?? null,
  }
}

function pickSkill(item) {
  return {
    id: item?.id ?? null,
    name: item?.name ?? null,
    description: item?.description ?? null,
    location: item?.location ?? null,
    autoinvoke: item?.autoinvoke ?? null,
  }
}

function pickCommand(item) {
  return {
    id: item?.id ?? item?.name ?? null,
    name: item?.name ?? null,
    description: item?.description ?? null,
  }
}

function pickPlugin(item) {
  return {
    id: item?.id ?? item?.name ?? null,
    name: item?.name ?? null,
    source: item?.source ?? null,
  }
}

function parseSkillFile(skillID) {
  const file = path.join(skillRoot, skillID, "SKILL.md")
  const text = fs.readFileSync(file, "utf8").replace(/\r\n/g, "\n")
  const match = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/u.exec(text)
  if (!match) throw new Error(`Invalid skill frontmatter: ${file}`)

  const metadata = {}
  for (const line of match[1].split("\n")) {
    const entry = /^([A-Za-z0-9_-]+):\s*(.*)$/u.exec(line)
    if (!entry) continue
    metadata[entry[1]] = entry[2].replace(/^["']|["']$/gu, "")
  }

  return {
    id: skillID,
    name: metadata.name || skillID,
    description: metadata.description || "",
    location: file,
    content: match[2].trim(),
  }
}

const skillIDs = [
  "zeus-diagnostics",
  "zeus-migration",
  "zeus-agents",
  "zeus-commands",
  "zeus-skills",
]

export default Plugin.define({
  id: "openzeus",

  async setup(ctx) {
    const skills = skillIDs.map(parseSkillFile)

    await ctx.skill.transform((editor) => {
      for (const skill of skills) {
        if (editor.get(skill.id)) continue
        editor.add(skill)
      }
    })

    await ctx.tool.transform((editor) => {
      editor.namespace({
        name: "openzeus",
        description: "Inspect the live OpenCode runtime without exposing credential values.",
      })

      editor.add({
        name: "runtime",
        description: "Return a safe live inventory of active OpenCode agents, skills, commands, plugins, version, and current location.",
        input: {
          type: "object",
          properties: {},
          additionalProperties: false,
        },
        options: { namespace: "openzeus", codemode: true },
        execute: async () => {
          const [agentsResult, skillsResult, commandsResult, pluginsResult] = await Promise.all([
            ctx.agent.list(),
            ctx.skill.list(),
            ctx.command.list(),
            ctx.plugin.list(),
          ])

          const result = {
            schemaVersion: 1,
            mode: "live-runtime",
            openCodeVersion: ctx.app.version,
            location: {
              directory: ctx.location.directory,
              workspaceID: ctx.location.workspaceID ?? null,
              project: {
                id: ctx.location.project?.id ?? null,
                directory: ctx.location.project?.directory ?? null,
                canonical: ctx.location.project?.canonical ?? null,
              },
            },
            inventory: {
              agents: listData(agentsResult).map(pickAgent),
              skills: listData(skillsResult).map(pickSkill),
              commands: listData(commandsResult).map(pickCommand),
              plugins: listData(pluginsResult).map(pickPlugin),
            },
          }

          return { content: JSON.stringify(result, null, 2) }
        },
      })
    })
  },
})
