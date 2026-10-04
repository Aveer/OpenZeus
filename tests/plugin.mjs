import assert from "node:assert/strict"
import plugin from "../src/plugin.js"

assert.equal(plugin.id, "openzeus")
assert.equal(typeof plugin.setup, "function")

const registeredSkills = []
const registeredTools = []
let namespace = null

const response = (data) => ({ data })

const ctx = {
  app: { version: "2.test" },
  location: {
    directory: "/workspace/current",
    workspaceID: "workspace-test",
    project: {
      id: "project-test",
      directory: "/workspace",
      canonical: "/workspace",
    },
  },
  agent: {
    list: async () => response([
      { id: "build", name: "Build", description: "Build agent", mode: "primary", prompt: "hidden" },
    ]),
  },
  skill: {
    list: async () => response([
      { id: "existing", name: "Existing", description: "Existing skill", location: "/existing/SKILL.md", content: "hidden" },
    ]),
    transform: async (callback) => {
      const existing = new Map([["existing", {}]])
      callback({
        get(id) { return existing.get(id) },
        add(skill) {
          registeredSkills.push(skill)
          existing.set(skill.id, skill)
        },
      })
      return { dispose: async () => {} }
    },
  },
  command: {
    list: async () => response([{ name: "help", description: "Help command", template: "hidden" }]),
  },
  plugin: {
    list: async () => response([{ id: "openzeus", name: "OpenZeus", source: { type: "package", package: "openzeus" }, options: { secret: "hidden" } }]),
  },
  tool: {
    transform: async (callback) => {
      callback({
        namespace(value) { namespace = value },
        add(tool) { registeredTools.push(tool) },
      })
      return { dispose: async () => {} }
    },
  },
}

await plugin.setup(ctx)

assert.equal(namespace.name, "openzeus")
assert.deepEqual(
  registeredSkills.map((skill) => skill.id).sort(),
  ["zeus-agents", "zeus-commands", "zeus-diagnostics", "zeus-migration", "zeus-skills"].sort(),
)
for (const skill of registeredSkills) {
  assert.ok(skill.description.length > 0)
  assert.ok(skill.content.length > 0)
  assert.ok(skill.location.endsWith("SKILL.md"))
}

const runtime = registeredTools.find((tool) => tool.name === "runtime")
assert.ok(runtime)
const output = await runtime.execute({})
const data = JSON.parse(output.content)

assert.equal(data.mode, "live-runtime")
assert.equal(data.openCodeVersion, "2.test")
assert.equal(data.location.directory, "/workspace/current")
assert.equal(data.inventory.agents[0].id, "build")
assert.equal(data.inventory.skills[0].id, "existing")
assert.equal(data.inventory.commands[0].name, "help")
assert.equal(data.inventory.plugins[0].id, "openzeus")
assert.equal("prompt" in data.inventory.agents[0], false)
assert.equal("content" in data.inventory.skills[0], false)
assert.equal("template" in data.inventory.commands[0], false)
assert.equal("options" in data.inventory.plugins[0], false)

console.log("plugin ok")
