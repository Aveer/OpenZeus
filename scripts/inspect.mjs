#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";

function usage() {
  process.stdout.write(
    "Usage: openzeus inspect [--target DIR] [--json]\n\n" +
    "Inspect filesystem-visible OpenCode configuration and asset sources.\n" +
    "Secret environment/config values are never emitted.\n"
  );
}

function parseArgs(argv) {
  let target = process.cwd();
  let json = false;
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--json") {
      json = true;
    } else if (arg === "--target") {
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
  return { target: path.resolve(target), json };
}

function exists(p) {
  try { return fs.existsSync(p); } catch { return false; }
}

function realpathSafe(p) {
  try { return fs.realpathSync(p); } catch { return path.resolve(p); }
}

function gitRoot(target) {
  try {
    return realpathSafe(execFileSync("git", ["-C", target, "rev-parse", "--show-toplevel"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"]
    }).trim());
  } catch {
    return realpathSafe(target);
  }
}

function ancestorChain(root, target) {
  root = realpathSafe(root);
  target = realpathSafe(target);
  const rel = path.relative(root, target);
  if (rel === ".." || rel.startsWith(".." + path.sep) || path.isAbsolute(rel)) return [target];
  const out = [];
  let cur = target;
  while (true) {
    out.push(cur);
    if (cur === root) break;
    const parent = path.dirname(cur);
    if (parent === cur) break;
    cur = parent;
  }
  return out.reverse();
}

function frontmatter(file) {
  let content;
  try { content = fs.readFileSync(file, "utf8").replace(/\r\n/g, "\n"); }
  catch { return { keys: new Set(), values: {} }; }
  if (!content.startsWith("---\n")) return { keys: new Set(), values: {} };
  const end = content.indexOf("\n---", 4);
  if (end < 0) return { keys: new Set(), values: {} };
  const keys = new Set();
  const values = {};
  for (const line of content.slice(4, end).split("\n")) {
    const match = /^([A-Za-z0-9_-]+):\s*(.*)$/.exec(line);
    if (!match) continue;
    keys.add(match[1]);
    values[match[1]] = match[2].replace(/^["']|["']$/g, "");
  }
  return { keys, values };
}

function listDir(dir) {
  try { return fs.readdirSync(dir, { withFileTypes: true }); }
  catch { return []; }
}

function addMarkdownFiles(inventory, type, dir, source, precedence, warnings) {
  for (const entry of listDir(dir)) {
    if (!entry.isFile() || !entry.name.endsWith(".md")) continue;
    const file = path.join(dir, entry.name);
    const id = entry.name.slice(0, -3);
    const fm = frontmatter(file);
    inventory[type].push({ id, path: realpathSafe(file), source, precedence });

    if (type === "agents") {
      for (const key of ["permission", "tools", "temperature", "top_p", "prompt", "disable", "maxSteps"]) {
        if (!fm.keys.has(key)) continue;
        warnings.push({
          code: "legacy_agent_" + key.toLowerCase(),
          severity: "warning",
          path: realpathSafe(file),
          message: "Agent uses legacy top-level field '" + key + "'."
        });
      }
    }

    if (type === "commands" && fm.keys.has("subtask")) {
      warnings.push({
        code: "legacy_command_subtask",
        severity: "warning",
        path: realpathSafe(file),
        message: "Command uses deprecated 'subtask'; current OpenCode uses 'subagent'."
      });
    }
  }
}

function addSkills(inventory, dir, source, precedence, warnings) {
  for (const entry of listDir(dir)) {
    if (!entry.isDirectory()) continue;
    const file = path.join(dir, entry.name, "SKILL.md");
    if (!exists(file)) continue;
    const fm = frontmatter(file);
    inventory.skills.push({
      id: entry.name,
      path: realpathSafe(file),
      source,
      precedence
    });
    if (!fm.keys.has("description")) {
      warnings.push({
        code: "skill_missing_description",
        severity: "warning",
        path: realpathSafe(file),
        message: "Skill is missing a description in SKILL.md frontmatter."
      });
    }
  }
}

function addPlugins(inventory, dir, source, precedence) {
  for (const entry of listDir(dir)) {
    if (!entry.isFile() || !/\.(js|mjs|cjs|ts|mts|cts)$/.test(entry.name)) continue;
    inventory.plugins.push({
      id: entry.name.replace(/\.[^.]+$/, ""),
      path: realpathSafe(path.join(dir, entry.name)),
      source,
      precedence
    });
  }
}

function addConfig(configSources, seen, kind, candidate) {
  if (!candidate) return;
  const resolved = path.resolve(candidate);
  if (seen.has(resolved)) return;
  seen.add(resolved);
  configSources.push({ kind, path: resolved, exists: exists(resolved) });
}

function markWinners(inventory) {
  const collisions = [];
  for (const [type, entries] of Object.entries(inventory)) {
    entries.sort((a, b) => a.precedence - b.precedence || a.path.localeCompare(b.path));
    const groups = new Map();
    for (const entry of entries) {
      if (!groups.has(entry.id)) groups.set(entry.id, []);
      groups.get(entry.id).push(entry);
    }
    for (const [id, group] of groups) {
      const winner = group[group.length - 1];
      for (const item of group) item.winner = item === winner;
      if (group.length > 1) {
        collisions.push({
          type: type.slice(0, -1),
          id,
          winner: { source: winner.source, path: winner.path },
          shadowed: group.slice(0, -1).map(x => ({ source: x.source, path: x.path }))
        });
      }
    }
  }
  return collisions;
}

function detectOpenCodeVersion() {
  // Filesystem mode intentionally does not execute OpenCode. A shim, version
  // manager, or interactive launcher can have side effects or block CI.
  // A future live-runtime adapter/plugin can provide the authoritative version.
  return null;
}

function printHuman(result) {
  console.log("OpenZeus inspect (filesystem view)");
  console.log("Target: " + result.target);
  console.log("Workspace root: " + result.workspaceRoot);
  console.log("Config root: " + result.configRoot);
  console.log("OpenCode version: " + (result.openCodeVersion || "not queried in filesystem mode"));
  console.log("");
  console.log(
    "Inventory: " +
    result.inventory.agents.length + " agents, " +
    result.inventory.skills.length + " skills, " +
    result.inventory.commands.length + " commands, " +
    result.inventory.plugins.length + " local plugins"
  );
  console.log("Collisions: " + result.collisions.length);
  console.log("Warnings: " + result.warnings.length);

  if (result.collisions.length) {
    console.log("\nCollisions");
    for (const collision of result.collisions) {
      console.log("- " + collision.type + " " + collision.id + " -> " + collision.winner.source);
    }
  }

  if (result.warnings.length) {
    console.log("\nWarnings");
    for (const warning of result.warnings) {
      console.log("- [" + warning.code + "] " + warning.message + " (" + warning.path + ")");
    }
  }

  const presentSources = result.configSources.filter(source => source.exists);
  console.log("\nConfig sources");
  if (!presentSources.length && !result.environment.inlineConfigPresent) {
    console.log("- no filesystem config file detected");
  }
  for (const source of presentSources) {
    console.log("- " + source.kind + ": " + source.path);
  }
  if (result.environment.inlineConfigPresent) {
    console.log("- inline: OPENCODE_CONFIG_CONTENT is set (value hidden)");
  }

  console.log("\nLimitation: " + result.limitations[0]);
}

let args;
try { args = parseArgs(process.argv.slice(2)); }
catch (error) {
  console.error(String(error.message || error));
  usage();
  process.exit(2);
}

if (!exists(args.target) || !fs.statSync(args.target).isDirectory()) {
  console.error("Target directory does not exist: " + args.target);
  process.exit(2);
}

const target = realpathSafe(args.target);
const workspaceRoot = gitRoot(target);
const ancestors = ancestorChain(workspaceRoot, target);
const home = path.resolve(process.env.HOME || os.homedir());
const defaultConfigRoot = process.env.XDG_CONFIG_HOME
  ? path.join(path.resolve(process.env.XDG_CONFIG_HOME), "opencode")
  : path.join(home, ".config", "opencode");
const configRoot = path.resolve(
  process.env.OPENCODE_CONFIG_DIR ||
  process.env.OPENZEUS_CONFIG_DIR ||
  defaultConfigRoot
);

const inventory = { agents: [], skills: [], commands: [], plugins: [] };
const warnings = [];
const configSources = [];
const seenConfig = new Set();

addConfig(configSources, seenConfig, "global", path.join(configRoot, "opencode.json"));
addConfig(configSources, seenConfig, "global", path.join(configRoot, "opencode.jsonc"));

if (process.env.OPENCODE_CONFIG) {
  addConfig(configSources, seenConfig, "explicit-env", process.env.OPENCODE_CONFIG);
}

for (const dir of ancestors) {
  addConfig(configSources, seenConfig, "project", path.join(dir, "opencode.json"));
  addConfig(configSources, seenConfig, "project", path.join(dir, "opencode.jsonc"));
  addConfig(configSources, seenConfig, "project-opencode", path.join(dir, ".opencode", "opencode.json"));
  addConfig(configSources, seenConfig, "project-opencode", path.join(dir, ".opencode", "opencode.jsonc"));
}

for (const oldName of ["tui.json", "tui.jsonc"]) {
  const oldPath = path.join(configRoot, oldName);
  if (!exists(oldPath)) continue;
  warnings.push({
    code: "legacy_tui_config",
    severity: "warning",
    path: realpathSafe(oldPath),
    message: "Legacy V1 terminal config detected; OpenCode V2 uses global cli.json."
  });
}

addMarkdownFiles(inventory, "agents", path.join(configRoot, "agents"), "global-opencode", 100, warnings);
addMarkdownFiles(inventory, "commands", path.join(configRoot, "commands"), "global-opencode", 100, warnings);
addPlugins(inventory, path.join(configRoot, "plugins"), "global-opencode", 100);

ancestors.forEach((dir, index) => {
  const base = path.join(dir, ".opencode");
  const relative = path.relative(workspaceRoot, dir) || ".";
  const source = "project-opencode:" + relative;
  addMarkdownFiles(inventory, "agents", path.join(base, "agents"), source, 200 + index, warnings);
  addMarkdownFiles(inventory, "commands", path.join(base, "commands"), source, 200 + index, warnings);
  addPlugins(inventory, path.join(base, "plugins"), source, 200 + index);
});

addSkills(inventory, path.join(home, ".claude", "skills"), "global-claude", 100, warnings);
ancestors.forEach((dir, index) => addSkills(
  inventory,
  path.join(dir, ".claude", "skills"),
  "project-claude:" + (path.relative(workspaceRoot, dir) || "."),
  110 + index,
  warnings
));

addSkills(inventory, path.join(home, ".agents", "skills"), "global-agents", 200, warnings);
ancestors.forEach((dir, index) => addSkills(
  inventory,
  path.join(dir, ".agents", "skills"),
  "project-agents:" + (path.relative(workspaceRoot, dir) || "."),
  210 + index,
  warnings
));

addSkills(inventory, path.join(configRoot, "skills"), "global-opencode", 300, warnings);
ancestors.forEach((dir, index) => addSkills(
  inventory,
  path.join(dir, ".opencode", "skills"),
  "project-opencode:" + (path.relative(workspaceRoot, dir) || "."),
  310 + index,
  warnings
));

const collisions = markWinners(inventory);
for (const collision of collisions) {
  warnings.push({
    code: "asset_shadowing",
    severity: "info",
    path: collision.winner.path,
    message: collision.type + " '" + collision.id + "' shadows " +
      collision.shadowed.length + " earlier filesystem source(s)."
  });
}

const result = {
  schemaVersion: 1,
  mode: "filesystem",
  target,
  workspaceRoot,
  configRoot,
  openCodeVersion: detectOpenCodeVersion(),
  environment: {
    opencodeConfigSet: Boolean(process.env.OPENCODE_CONFIG),
    opencodeConfigDirSet: Boolean(process.env.OPENCODE_CONFIG_DIR),
    xdgConfigHomeSet: Boolean(process.env.XDG_CONFIG_HOME),
    inlineConfigPresent: Boolean(process.env.OPENCODE_CONFIG_CONTENT)
  },
  configSources,
  inventory,
  collisions,
  warnings,
  limitations: [
    "Filesystem mode does not execute OpenCode and cannot fully resolve remote/managed configuration, config-declared assets, npm plugins, built-in skills, explicit skill catalogs, or the authoritative OpenCode version. It reports that boundary instead of guessing."
  ]
};

if (args.json) {
  process.stdout.write(JSON.stringify(result, null, 2) + "\n");
} else {
  printHuman(result);
}
