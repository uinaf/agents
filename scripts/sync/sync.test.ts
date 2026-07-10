import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import {
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readlinkSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { afterEach, test } from "node:test";
import { fileURLToPath } from "node:url";

import { main, type Runtime } from "./sync.ts";

type CommandCall = {
  command: string;
  args: readonly string[];
};

type FixtureOptions = {
  branch?: string;
  commonDir?: string;
  falseSuccesses?: ReadonlySet<string>;
  failures?: ReadonlyMap<string, FixtureFailure>;
  gitDir?: string;
};

type FixtureFailure = {
  stderr: string;
  stdout: string;
};

class BufferWriter {
  value = "";

  write(message: string): void {
    this.value += message;
  }
}

class FixtureRuntime implements Runtime {
  readonly env: NodeJS.ProcessEnv;
  readonly stdout = new BufferWriter();
  readonly stderr = new BufferWriter();
  readonly calls: CommandCall[] = [];
  readonly installedCommands = new Set(["claude", "codex"]);
  readonly branch: string;
  readonly commonDir: string;
  readonly falseSuccesses: ReadonlySet<string>;
  readonly failures: ReadonlyMap<string, FixtureFailure>;
  readonly gitDir: string;
  readonly home: string;
  readonly repoDir: string;

  constructor(repoDir: string, home: string, options: FixtureOptions = {}) {
    this.repoDir = repoDir;
    this.branch = options.branch ?? "main";
    this.commonDir = options.commonDir ?? ".git";
    this.falseSuccesses = options.falseSuccesses ?? new Set();
    this.failures = options.failures ?? new Map();
    this.gitDir = options.gitDir ?? ".git";
    this.home = home;
    this.env = { HOME: home, SKILLS_CLI_VERSION: "test-version" };
  }

  commandExists(command: string): boolean {
    return this.installedCommands.has(command);
  }

  run(command: string, args: readonly string[]): { status: number; stdout: string; stderr: string } {
    this.calls.push({ command, args });

    if (command === "git" && args.includes("rev-parse")) {
      if (args.includes("--show-toplevel")) {
        return { status: 0, stdout: `${this.repoDir}\n`, stderr: "" };
      }
      if (args.includes("--git-dir")) {
        return { status: 0, stdout: `${this.gitDir}\n`, stderr: "" };
      }
      if (args.includes("--git-common-dir")) {
        return { status: 0, stdout: `${this.commonDir}\n`, stderr: "" };
      }
      if (args.includes("--abbrev-ref")) {
        return { status: 0, stdout: `${this.branch}\n`, stderr: "" };
      }
      return { status: 99, stdout: "", stderr: `Unexpected git rev-parse: ${args.join(" ")}` };
    }
    if (command === "git" && args.includes("pull")) {
      return { status: 0, stdout: "", stderr: "" };
    }
    if (command === "npx") {
      const skillFlag = args.indexOf("-s");
      const skill = skillFlag >= 0 ? args[skillFlag + 1] : undefined;
      if (skill === undefined) {
        throw new Error("skills installer call must include -s <name>");
      }
      const diagnostic = this.failures.get(skill);
      if (diagnostic !== undefined) {
        return { status: 1, stdout: diagnostic.stdout, stderr: diagnostic.stderr };
      }
      if (!this.falseSuccesses.has(skill)) {
        const skillDir = join(this.home, ".agents", "skills", skill);
        mkdirSync(skillDir, { recursive: true });
        writeFileSync(join(skillDir, "SKILL.md"), `---\nname: ${skill}\ndescription: Fixture\n---\n`);
      }
      return { status: 0, stdout: "", stderr: "" };
    }

    return { status: 99, stdout: "", stderr: `Unexpected command: ${command}` };
  }
}

const temporaryDirectories: string[] = [];

afterEach(() => {
  for (const path of temporaryDirectories.splice(0)) {
    rmSync(path, { force: true, recursive: true });
  }
});

function createFixture(): { repoDir: string; home: string } {
  const root = mkdtempSync(join(tmpdir(), "uinaf-agents-sync-"));
  temporaryDirectories.push(root);
  const repoDir = join(root, "repo");
  const home = join(root, "home");

  mkdirSync(join(repoDir, "rules"), { recursive: true });
  mkdirSync(join(repoDir, "scripts", "sync"), { recursive: true });
  mkdirSync(home, { recursive: true });
  writeFileSync(join(repoDir, "rules", "agents.md"), "# Fixture agent rules\n");
  writeFileSync(
    join(repoDir, "scripts", "sync", "skills.json"),
    JSON.stringify(
      {
        skills: [
          { name: "ok-before", source: "fixture/before" },
          { name: "fails-first", source: "fixture/failure-first" },
          { name: "ok-middle", source: "fixture/middle" },
          { name: "fails-second", source: "fixture/failure-second" },
          { name: "ok-after", source: "fixture/after" },
        ],
      },
      null,
      2,
    ),
  );

  return { repoDir, home };
}

function installedSkillNames(runtime: FixtureRuntime): string[] {
  return runtime.calls
    .filter((call) => call.command === "npx")
    .map((call) => {
      const skillFlag = call.args.indexOf("-s");
      const skill = skillFlag >= 0 ? call.args[skillFlag + 1] : undefined;
      if (skill === undefined) {
        throw new Error("recorded skills installer call must include -s <name>");
      }
      return skill;
    });
}

test("reports every installer failure after attempting the full manifest", () => {
  const { repoDir, home } = createFixture();
  const runtime = new FixtureRuntime(repoDir, home, {
    failures: new Map([
      [
        "fails-first",
        {
          stdout: "installer token=stdout-secret",
          stderr: "npm error code E401\nnpm error token=stderr-secret",
        },
      ],
      ["fails-second", { stdout: "", stderr: "package source was not found" }],
    ]),
  });

  assert.equal(main([], runtime), 1);
  assert.deepEqual(installedSkillNames(runtime), [
    "ok-before",
    "fails-first",
    "ok-middle",
    "fails-second",
    "ok-after",
  ]);
  assert.match(runtime.stderr.value, /Skill installation failed for 2 skills:/);
  assert.match(runtime.stderr.value, /fails-first \(fixture\/failure-first, exit 1\)/);
  assert.match(runtime.stderr.value, /fails-second \(fixture\/failure-second, exit 1\)/);
  assert.match(runtime.stderr.value, /installer token=\[REDACTED\]/);
  assert.match(runtime.stderr.value, /npm error token=\[REDACTED\]/);
  assert.match(runtime.stderr.value, /package source was not found/);
  assert.doesNotMatch(runtime.stderr.value, /stdout-secret|stderr-secret/);
  assert.doesNotMatch(runtime.stdout.value, /Done\./);
});

test("rejects a false-success installer result when the installed artifact is missing", () => {
  const { repoDir, home } = createFixture();
  const runtime = new FixtureRuntime(repoDir, home, {
    falseSuccesses: new Set(["ok-middle"]),
  });

  assert.equal(main([], runtime), 1);
  assert.deepEqual(installedSkillNames(runtime), [
    "ok-before",
    "fails-first",
    "ok-middle",
    "fails-second",
    "ok-after",
  ]);
  assert.match(runtime.stderr.value, /ok-middle \(fixture\/middle, invalid installed artifact\)/);
  assert.match(runtime.stderr.value, /installer reported success but .*SKILL\.md is missing/);
  assert.doesNotMatch(runtime.stdout.value, /Done\./);
});

for (const scenario of [
  {
    name: "refuses a linked worktree before pulling or changing global state",
    options: { commonDir: "/tmp/agents/.git", gitDir: "/tmp/agents/.git/worktrees/feature" },
    message: /primary checkout, not a linked worktree/,
  },
  {
    name: "refuses a non-main branch before pulling or changing global state",
    options: { branch: "feature/sync" },
    message: /main branch; current branch is feature\/sync/,
  },
]) {
  test(scenario.name, () => {
    const { repoDir, home } = createFixture();
    const runtime = new FixtureRuntime(repoDir, home, scenario.options);

    assert.equal(main([], runtime), 1);
    assert.match(runtime.stderr.value, scenario.message);
    assert.equal(
      runtime.calls.some((call) => call.command === "git" && call.args.includes("pull")),
      false,
    );
    assert.equal(installedSkillNames(runtime).length, 0);
  });
}

test("completes a successful sync and preserves rules links", () => {
  const { repoDir, home } = createFixture();
  const runtime = new FixtureRuntime(repoDir, home);
  runtime.env.SKILLS_CLI_VERSION = "";

  assert.equal(main([], runtime), 0);
  assert.match(runtime.stdout.value, /Done\./);
  assert.equal(runtime.calls.find((call) => call.command === "npx")?.args[0], "skills@1.5.7");
  assert.equal(
    readFileSync(join(repoDir, "rules", "agents.final.md"), "utf8"),
    "# Agent Instructions\n\n" +
      "Generated by scripts/sync/sync.sh from rules/agents.md and optional rules/agents.local.md. Do not edit directly.\n\n" +
      "---\n\n" +
      "# Fixture agent rules\n",
  );
  const finalRules = join(repoDir, "rules", "agents.final.md");
  assert.equal(readlinkSync(join(home, ".claude", "CLAUDE.md")), finalRules);
  assert.equal(readlinkSync(join(home, ".codex", "AGENTS.md")), finalRules);
});

test("rejects an invalid manifest with an actionable error", () => {
  const { repoDir, home } = createFixture();
  writeFileSync(
    join(repoDir, "scripts", "sync", "skills.json"),
    '{"skills":[{"name":"missing-source"}]}',
  );
  const runtime = new FixtureRuntime(repoDir, home);

  assert.equal(main([], runtime), 1);
  assert.match(runtime.stderr.value, /Invalid skills manifest/);
  assert.match(runtime.stderr.value, /expected non-empty name\/source strings/);
  assert.equal(installedSkillNames(runtime).length, 0);
});

test("the shell compatibility entrypoint runs the typed CLI", () => {
  const scriptPath = join(dirname(fileURLToPath(import.meta.url)), "sync.sh");
  const result = spawnSync(scriptPath, ["unexpected"], { encoding: "utf8" });

  assert.equal(result.status, 2);
  assert.match(result.stderr, /Usage: \.\/scripts\/sync\/sync\.sh/);
});
