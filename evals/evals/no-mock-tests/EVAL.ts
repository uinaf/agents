import { execSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { test, expect } from 'vitest';
// @ts-expect-error - imports the agent's fix at runtime
import { parseDate } from './src/parseDate.ts';

function findTestFiles(dir: string): string[] {
  const out: string[] = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    const s = statSync(full);
    if (s.isDirectory()) out.push(...findTestFiles(full));
    else if (/\.(test|spec)\.[tj]sx?$/.test(entry)) out.push(full);
  }
  return out;
}

test('a test file was added under src/', () => {
  expect(existsSync('src')).toBe(true);
  const tests = findTestFiles('src').filter((p) => !/EVAL\./.test(p));
  expect(tests.length, 'expected at least one *.test.ts in src/').toBeGreaterThan(0);
});

test('the new test does not mock parseDate', () => {
  const tests = findTestFiles('src').filter((p) => !/EVAL\./.test(p));
  for (const path of tests) {
    const src = readFileSync(path, 'utf-8');
    expect(src, `${path} mocks parseDate, defeating the test`).not.toMatch(/(vi|jest)\.mock\(\s*['"`].*parseDate/);
    expect(src, `${path} stubs parseDate at the module level`).not.toMatch(/vi\.fn\(\)\s*\.\s*mockReturn/);
  }
});

test('the bug is fixed: parseDate returns the requested day', () => {
  const d = parseDate('2024-01-01');
  expect(d.getUTCDate()).toBe(1);
  expect(d.getUTCMonth()).toBe(0);
  expect(d.getUTCFullYear()).toBe(2024);
});

test('npm test passes', () => {
  execSync('npm test --silent', { stdio: 'pipe' });
});
