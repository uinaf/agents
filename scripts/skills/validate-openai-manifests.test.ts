import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, test } from "node:test";

import {
  characterCount,
  extractDefaultPrompt,
  MAX_DEFAULT_PROMPT_LENGTH,
  validateOpenAiManifests,
} from "./validate-openai-manifests.ts";

const temporaryDirectories: string[] = [];

afterEach(() => {
  for (const path of temporaryDirectories.splice(0)) {
    rmSync(path, { force: true, recursive: true });
  }
});

function createSkillsFixture(prompts: Readonly<Record<string, string>>): string {
  const skillsDir = mkdtempSync(join(tmpdir(), "uinaf-openai-manifests-"));
  temporaryDirectories.push(skillsDir);

  for (const [name, prompt] of Object.entries(prompts)) {
    const agentsDir = join(skillsDir, name, "agents");
    mkdirSync(agentsDir, { recursive: true });
    const indentedPrompt = prompt
      .split("\n")
      .map((line) => `    ${line}`)
      .join("\n");
    writeFileSync(
      join(agentsDir, "openai.yaml"),
      `interface:\n  display_name: "${name}"\n  default_prompt: |-\n${indentedPrompt}`,
    );
  }

  return skillsDir;
}

test("extracts a literal multiline default prompt", () => {
  assert.equal(
    extractDefaultPrompt("interface:\n  default_prompt: |\n    first line\n\n    third line\n"),
    "first line\n\nthird line\n",
  );
});

test("supports stripped literal block prompts", () => {
  assert.equal(
    extractDefaultPrompt("interface:\n  default_prompt: |-\n    first line\n\n    third line\n"),
    "first line\n\nthird line",
  );
});

test("parses whitespace-only block lines using YAML semantics", () => {
  const longTail = "x".repeat(MAX_DEFAULT_PROMPT_LENGTH + 1);
  const skillsDir = mkdtempSync(join(tmpdir(), "uinaf-openai-manifests-"));
  temporaryDirectories.push(skillsDir);
  const agentsDir = join(skillsDir, "whitespace", "agents");
  mkdirSync(agentsDir, { recursive: true });
  writeFileSync(
    join(agentsDir, "openai.yaml"),
    `interface:\n  default_prompt: |-\n    short\n  \n    ${longTail}\n`,
  );

  assert.deepEqual(validateOpenAiManifests(skillsDir), [
    {
      kind: "over-limit",
      length: "short\n\n".length + longTail.length,
      path: "whitespace/agents/openai.yaml",
    },
  ]);
});

test("accepts prompts at the Codex character limit", () => {
  const skillsDir = createSkillsFixture({ boundary: "x".repeat(MAX_DEFAULT_PROMPT_LENGTH) });

  assert.deepEqual(validateOpenAiManifests(skillsDir), []);
});

test("counts non-BMP Unicode prompts by code point", () => {
  const boundary = "🦞".repeat(MAX_DEFAULT_PROMPT_LENGTH);
  const skillsDir = createSkillsFixture({ boundary });

  assert.equal(characterCount(boundary), MAX_DEFAULT_PROMPT_LENGTH);
  assert.deepEqual(validateOpenAiManifests(skillsDir), []);
});

test("reports every prompt over the Codex character limit", () => {
  const skillsDir = createSkillsFixture({
    "too-long-b": "x".repeat(MAX_DEFAULT_PROMPT_LENGTH + 2),
    "too-long-a": "x".repeat(MAX_DEFAULT_PROMPT_LENGTH + 1),
  });

  assert.deepEqual(validateOpenAiManifests(skillsDir), [
    {
      kind: "over-limit",
      length: MAX_DEFAULT_PROMPT_LENGTH + 1,
      path: "too-long-a/agents/openai.yaml",
    },
    {
      kind: "over-limit",
      length: MAX_DEFAULT_PROMPT_LENGTH + 2,
      path: "too-long-b/agents/openai.yaml",
    },
  ]);
});

test("measures quoted YAML prompts instead of bypassing validation", () => {
  const skillsDir = mkdtempSync(join(tmpdir(), "uinaf-openai-manifests-"));
  temporaryDirectories.push(skillsDir);
  const agentsDir = join(skillsDir, "quoted", "agents");
  mkdirSync(agentsDir, { recursive: true });
  writeFileSync(
    join(agentsDir, "openai.yaml"),
    `interface:\n  default_prompt: "${"x".repeat(MAX_DEFAULT_PROMPT_LENGTH + 1)}"\n`,
  );

  assert.deepEqual(validateOpenAiManifests(skillsDir), [
    {
      kind: "over-limit",
      length: MAX_DEFAULT_PROMPT_LENGTH + 1,
      path: "quoted/agents/openai.yaml",
    },
  ]);
});

test("rejects non-string default prompts", () => {
  const skillsDir = mkdtempSync(join(tmpdir(), "uinaf-openai-manifests-"));
  temporaryDirectories.push(skillsDir);
  const agentsDir = join(skillsDir, "invalid", "agents");
  mkdirSync(agentsDir, { recursive: true });
  writeFileSync(join(agentsDir, "openai.yaml"), "interface:\n  default_prompt: [not, a, string]\n");

  assert.deepEqual(validateOpenAiManifests(skillsDir), [
    {
      diagnostic: "interface.default_prompt must be a string",
      kind: "invalid-manifest",
      path: "invalid/agents/openai.yaml",
    },
  ]);
});
