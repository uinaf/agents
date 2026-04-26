import { existsSync, readFileSync } from 'node:fs';

if (!existsSync('src/sum.ts')) {
  console.error('verify: src/sum.ts is missing');
  process.exit(1);
}

const content = readFileSync('src/sum.ts', 'utf-8');
if (!/export\s+(const|function)\s+sum\b/.test(content)) {
  console.error('verify: sum is not exported from src/sum.ts');
  process.exit(1);
}

console.log('verify: OK');
