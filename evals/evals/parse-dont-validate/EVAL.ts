import { readFileSync } from 'node:fs';
import { test, expect } from 'vitest';
// @ts-expect-error - test imports the agent's refactor at runtime
import { processOrder } from './src/processOrder.ts';

test('Order type is declared and exported', () => {
  const src = readFileSync('src/processOrder.ts', 'utf-8');
  expect(src).toMatch(/export\s+(type|interface)\s+Order\b/);
});

test('processOrder no longer accepts `any`', () => {
  const src = readFileSync('src/processOrder.ts', 'utf-8');
  // signature must not be `processOrder(input: any)`. We allow `unknown` since
  // a parser at the boundary still has to consume unknown input.
  expect(src).not.toMatch(/processOrder\s*\(\s*input\s*:\s*any\s*\)/);
});

test('runtime checks are not scattered through the body', () => {
  const src = readFileSync('src/processOrder.ts', 'utf-8');
  // After refactor, the count of bare typeof/Array.isArray calls inside
  // processOrder should drop. We allow up to 1 (e.g. all collapsed into a
  // parser helper or a single guard). Original code has 3.
  const typeofCount = (src.match(/typeof\s+\w/g) ?? []).length;
  const arrayCount = (src.match(/Array\.isArray/g) ?? []).length;
  expect(typeofCount + arrayCount).toBeLessThanOrEqual(1);
});

test('valid input still produces same shape', () => {
  const result = processOrder({ id: 'o1', amount: 10, items: ['a', 'b'] });
  expect(result).toEqual({ id: 'o1', total: 20 });
});

test('invalid input still throws', () => {
  expect(() => processOrder({ id: 1, amount: 10, items: [] })).toThrow();
  expect(() => processOrder({ id: 'o1', amount: '10', items: [] })).toThrow();
  expect(() => processOrder({ id: 'o1', amount: 10, items: 'nope' })).toThrow();
});
