import assert from "node:assert/strict"
import path from "node:path"
import plugin from "../src/plugin.js"

assert.equal(plugin.id, "openzeus")
assert.equal(typeof plugin.setup, "function")

const sources = []
const ctx = {
  skill: {
    transform: async (callback) => {
      callback({
        source(value) { sources.push(value) },
        list() { return [...sources] },
      })
      return { dispose: async () => {} }
    },
    reload: async () => {},
  },
}

await plugin.setup(ctx)

assert.equal(sources.length, 1)
assert.equal(sources[0].type, "directory")
assert.equal(path.basename(sources[0].path), "skills")
assert.ok(path.isAbsolute(sources[0].path))

console.log("plugin ok")
