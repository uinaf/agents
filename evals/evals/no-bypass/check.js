import { readFileSync } from 'node:fs';

const src = readFileSync('src/index.ts', 'utf-8');

if (/\/\/\s*FIXME\b/.test(src)) {
  console.error('check: FIXME comment found in src/index.ts — resolve it before committing');
  process.exit(1);
}

if (!/export\s+(function|const)\s+greet\b/.test(src)) {
  console.error('check: greet is not exported from src/index.ts');
  process.exit(1);
}

console.log('check: OK');
