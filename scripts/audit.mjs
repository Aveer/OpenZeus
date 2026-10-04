#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const inspectScript = path.join(here, "inspect.mjs");

function usage() {
  process.stdout.write(
    "Usage: openzeus audit [--target DIR] [--json] [--ci]\n\n" +
    "Summarize actionable OpenCode findings from OpenZeus inspection.\n"
  );
}

function parseArgs(argv) {
  let target = process.cwd();
  let json = false;
  let ci = false;
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--json") json = true;
    else if (arg === "--ci") ci = true;
    else if (arg === "--target") {
      const value = argv[i + 1];
      if (!value || value.startsWith("--")) throw new Error("Missing value for --target");
      target = value;
      i += 1;
    } else if (arg === "-h" || arg === "--help") {
      usage();
      process.exit(0);
    } else {
      throw new Error("Unknown option: " + arg);
    }
  }
  return { target: path.resolve(target), json, ci };
}

function recommendation(finding) {
  if (finding.code === "asset_shadowing") {
    return "Inspect the winning and shadowed sources before changing either definition.";
  }
  if (finding.code === "legacy_tui_config") {
    return "Review migration to the global V2 cli.json client configuration.";
  }
  if (finding.code.startsWith("legacy_agent_")) {
    return "Review this agent with @OpenZeus and migrate only the legacy field(s) that affect current behavior.";
  }
  if (finding.code === "legacy_command_subtask") {
    return "Replace legacy subtask with native V2 subagent after verifying intended execution behavior.";
  }
  if (finding.code === "skill_missing_description") {
    return "Add a trigger-oriented skill description so OpenCode can advertise the skill reliably.";
  }
  return null;
}

let args;
try {
  args = parseArgs(process.argv.slice(2));
} catch (error) {
  console.error(String(error.message || error));
  usage();
  process.exit(2);
}

let inspection;
try {
  const output = execFileSync(process.execPath, [
    inspectScript,
    "--target",
    args.target,
    "--json"
  ], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "inherit"]
  });
  inspection = JSON.parse(output);
} catch (error) {
  console.error("OpenZeus audit could not complete inspection.");
  process.exit(2);
}

const findings = inspection.warnings.map((item) => ({
  ...item,
  recommendation: recommendation(item)
}));

const warningCount = findings.filter((item) => item.severity === "warning" || item.severity === "error").length;
const infoCount = findings.filter((item) => item.severity === "info").length;
const status = warningCount > 0 ? "warning" : "ok";

const result = {
  schemaVersion: 1,
  status,
  target: inspection.target,
  workspaceRoot: inspection.workspaceRoot,
  summary: {
    warnings: warningCount,
    info: infoCount,
    collisions: inspection.collisions.length,
    agents: inspection.inventory.agents.length,
    skills: inspection.inventory.skills.length,
    commands: inspection.inventory.commands.length,
    plugins: inspection.inventory.plugins.length
  },
  findings,
  limitations: inspection.limitations
};

if (args.json) {
  process.stdout.write(JSON.stringify(result, null, 2) + "\n");
} else {
  console.log("OpenZeus audit");
  console.log("Status: " + status);
  console.log(
    "Inventory: " +
    result.summary.agents + " agents, " +
    result.summary.skills + " skills, " +
    result.summary.commands + " commands, " +
    result.summary.plugins + " local plugins"
  );
  console.log(
    "Findings: " +
    result.summary.warnings + " warning(s), " +
    result.summary.info + " info"
  );

  if (!findings.length) {
    console.log("\nNo filesystem-visible OpenCode issues detected.");
  } else {
    console.log("\nFindings");
    for (const finding of findings) {
      console.log("- [" + finding.severity + "] " + finding.message);
      console.log("  " + finding.path);
      if (finding.recommendation) console.log("  Next: " + finding.recommendation);
    }
  }

  console.log("\nBoundary: " + inspection.limitations[0]);
}

if (args.ci && warningCount > 0) process.exit(1);
