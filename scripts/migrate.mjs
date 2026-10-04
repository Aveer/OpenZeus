#!/usr/bin/env node
import { execFileSync } from "node:child_process"
import path from "node:path"
import { fileURLToPath } from "node:url"

const here = path.dirname(fileURLToPath(import.meta.url))
const inspectScript = path.join(here, "inspect.mjs")

function usage() {
  process.stdout.write(
    "Usage: openzeus migrate --plan [--target DIR] [--json]\n\n" +
    "Build a non-mutating OpenCode migration plan from inspector findings.\n" +
    "Apply mode is intentionally not implemented yet.\n",
  )
}

function parseArgs(argv) {
  let target = process.cwd()
  let json = false
  let plan = false

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i]
    if (arg === "--plan") plan = true
    else if (arg === "--json") json = true
    else if (arg === "--target") {
      const value = argv[i + 1]
      if (!value || value.startsWith("--")) throw new Error("Missing value for --target")
      target = value
      i += 1
    } else if (arg === "--apply") {
      throw new Error("Apply mode is not implemented; no files were changed. Use --plan.")
    } else if (arg === "-h" || arg === "--help") {
      usage()
      process.exit(0)
    } else {
      throw new Error("Unknown option: " + arg)
    }
  }

  if (!plan) {
    throw new Error("Migration is plan-only for now. Pass --plan; no files were changed.")
  }

  return { target: path.resolve(target), json }
}

function actionFor(finding) {
  const base = {
    sourceCode: finding.code,
    path: finding.path,
    automatic: false,
  }

  switch (finding.code) {
    case "legacy_agent_permission":
      return {
        ...base,
        id: "agent-permissions-v2",
        kind: "agent",
        summary: "Convert legacy permission mapping to ordered V2 permissions.",
        details: [
          "Preserve the existing allow/ask/deny intent.",
          "Translate bash -> shell, task -> subagent, and write/patch -> edit where present.",
          "Review wildcard/resource semantics before applying.",
        ],
      }

    case "legacy_agent_tools":
      return {
        ...base,
        id: "agent-tools-v2",
        kind: "agent",
        summary: "Replace legacy tools gating with explicit V2 permission rules.",
        details: [
          "Derive the intended allow/deny behavior before removing the tools map.",
        ],
      }

    case "legacy_agent_disable":
      return {
        ...base,
        id: "agent-disabled-v2",
        kind: "agent",
        summary: "Rename legacy agent disable to disabled.",
        details: ["Preserve the existing boolean value."],
      }

    case "legacy_agent_temperature":
    case "legacy_agent_top_p":
    case "legacy_agent_prompt":
    case "legacy_agent_maxsteps":
      return {
        ...base,
        id: "agent-request-options-review",
        kind: "agent",
        summary: "Review legacy agent request/system fields against current V2 behavior.",
        details: [
          "Do not blindly move or delete this field.",
          "Confirm the current schema/provider/model behavior before changing it.",
        ],
      }

    case "legacy_command_subtask":
      return {
        ...base,
        id: "command-subagent-v2",
        kind: "command",
        summary: "Rename legacy command subtask to subagent.",
        details: [
          "Preserve the boolean value.",
          "Verify that the intended execution/delivery behavior remains the same.",
        ],
      }

    case "legacy_tui_config":
      return {
        ...base,
        id: "client-config-v2",
        kind: "client-config",
        summary: "Review migration from legacy tui.json(c) to V2 global cli.json.",
        details: [
          "Map only settings supported by current cli.json.",
          "Keep a backup of the old client config until the V2 client starts cleanly.",
        ],
      }

    default:
      return null
  }
}

let args
try {
  args = parseArgs(process.argv.slice(2))
} catch (error) {
  console.error(String(error.message || error))
  usage()
  process.exit(2)
}

let inspection
try {
  const output = execFileSync(process.execPath, [
    inspectScript,
    "--target",
    args.target,
    "--json",
  ], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "inherit"],
  })
  inspection = JSON.parse(output)
} catch {
  console.error("OpenZeus migration planning could not complete inspection.")
  process.exit(2)
}

const actions = []
const ignoredFindings = []

for (const finding of inspection.warnings) {
  const action = actionFor(finding)
  if (action) {
    actions.push(action)
  } else {
    ignoredFindings.push({
      code: finding.code,
      severity: finding.severity,
      path: finding.path,
      message: finding.message,
    })
  }
}

const result = {
  schemaVersion: 1,
  mode: "plan",
  mutatesFiles: false,
  target: inspection.target,
  workspaceRoot: inspection.workspaceRoot,
  actions,
  ignoredFindings,
  limitations: [
    ...inspection.limitations,
    "This command plans only. Every action requires review before any future apply implementation may mutate files.",
  ],
}

if (args.json) {
  process.stdout.write(JSON.stringify(result, null, 2) + "\n")
} else {
  console.log("OpenZeus migration plan")
  console.log("Target: " + result.target)
  console.log("Planned actions: " + actions.length)

  if (!actions.length) {
    console.log("\nNo filesystem-visible migration actions detected.")
  } else {
    console.log("\nActions")
    actions.forEach((action, index) => {
      console.log((index + 1) + ". " + action.summary)
      console.log("   " + action.path)
      for (const detail of action.details) {
        console.log("   - " + detail)
      }
      console.log("   Automatic apply: no")
    })
  }

  if (ignoredFindings.length) {
    console.log("\nNot migration actions")
    for (const finding of ignoredFindings) {
      console.log("- [" + finding.severity + "] " + finding.message)
    }
  }

  console.log("\nNo files were changed.")
}
