#!/usr/bin/env node

import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parse } from "yaml";

export const MAX_DEFAULT_PROMPT_LENGTH = 1_024;

export type InterfaceIssue =
  | {
      kind: "over-limit";
      length: number;
      path: string;
    }
  | {
      diagnostic: string;
      kind: "invalid-manifest";
      path: string;
    };

export class InvalidManifestError extends Error {}

export function characterCount(value: string): number {
  return Array.from(value).length;
}

function isStringKeyedObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

export function extractDefaultPrompt(source: string): string | undefined {
  let parsed: unknown;
  try {
    parsed = parse(source);
  } catch (error) {
    const diagnostic = error instanceof Error ? error.message : String(error);
    throw new InvalidManifestError(`invalid YAML: ${diagnostic}`);
  }

  if (!isStringKeyedObject(parsed)) {
    return undefined;
  }

  const interfaceValue = parsed.interface;
  if (!isStringKeyedObject(interfaceValue)) {
    return undefined;
  }

  const prompt = interfaceValue.default_prompt;
  if (prompt === undefined) {
    return undefined;
  }
  if (typeof prompt !== "string") {
    throw new InvalidManifestError("interface.default_prompt must be a string");
  }

  return prompt;
}

export function validateOpenAiManifests(skillsDir: string): InterfaceIssue[] {
  const issues: InterfaceIssue[] = [];

  for (const entry of readdirSync(skillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      continue;
    }

    const manifestPath = join(skillsDir, entry.name, "agents", "openai.yaml");
    if (!existsSync(manifestPath)) {
      continue;
    }

    const issuePath = relative(skillsDir, manifestPath);
    try {
      const prompt = extractDefaultPrompt(readFileSync(manifestPath, "utf8"));
      const length = prompt === undefined ? 0 : characterCount(prompt);
      if (length > MAX_DEFAULT_PROMPT_LENGTH) {
        issues.push({ kind: "over-limit", length, path: issuePath });
      }
    } catch (error) {
      if (!(error instanceof InvalidManifestError)) {
        throw error;
      }
      issues.push({ diagnostic: error.message, kind: "invalid-manifest", path: issuePath });
    }
  }

  return issues.sort((left, right) => left.path.localeCompare(right.path));
}

export function main(args: readonly string[]): number {
  if (args.length > 1) {
    process.stderr.write("Usage: node scripts/skills/validate-openai-manifests.ts [skills-dir]\n");
    return 2;
  }

  const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
  const skillsDir = resolve(args[0] ?? join(repoRoot, "skills"));
  const issues = validateOpenAiManifests(skillsDir);

  if (issues.length === 0) {
    process.stdout.write("OpenAI skill interface prompts are within the 1024-character limit.\n");
    return 0;
  }

  for (const issue of issues) {
    if (issue.kind === "invalid-manifest") {
      process.stderr.write(
        `${issue.path}: ${issue.diagnostic}.\n`,
      );
    } else {
      process.stderr.write(
        `${issue.path}: interface.default_prompt is ${issue.length} characters; maximum is ${MAX_DEFAULT_PROMPT_LENGTH}. ` +
          "Shorten the launch prompt and keep detailed workflow in SKILL.md.\n",
      );
    }
  }
  return 1;
}

const entrypoint = process.argv[1];
if (entrypoint !== undefined && resolve(entrypoint) === fileURLToPath(import.meta.url)) {
  process.exitCode = main(process.argv.slice(2));
}
