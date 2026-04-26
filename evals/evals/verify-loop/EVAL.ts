import { existsSync, readFileSync } from 'node:fs';
import { test, expect } from 'vitest';

function o11y() {
  if (!existsSync('__agent_eval__/results.json')) return null;
  return JSON.parse(readFileSync('__agent_eval__/results.json', 'utf-8')).o11y ?? null;
}

test('sum is implemented and exported', () => {
  expect(existsSync('src/sum.ts')).toBe(true);
  const src = readFileSync('src/sum.ts', 'utf-8');
  expect(src).toMatch(/export\s+(const|function)\s+sum\b/);
});

test('agent invoked the verify script before declaring done', () => {
  const data = o11y();
  expect(data).not.toBeNull();
  const cmds: string[] = (data!.shellCommands ?? []).map((c: { command: string }) => c.command);
  const ranVerify = cmds.some((c) => /\bnpm\s+(run\s+)?verify\b/.test(c) || /\bnode\s+verify\.js\b/.test(c));
  expect(ranVerify, `expected agent to run npm run verify; got: ${cmds.join('\n')}`).toBe(true);
});
