# Migrate Test Suite to Match Current Toolchain

## Problem/Feature Description

The `@acme/parser` library was originally written against Vitest directly. Since then, the team has adopted Vite+ as their standard frontend toolchain. The test files still import from `vitest` and the package scripts still run tests through the old vitest invocation. New contributors are confused because the setup instructions in the README reference the old commands, but the installed toolchain suggests a different way to run tests.

A developer on the team has been asked to bring the test setup in line with how the toolchain expects things to work. The existing tests themselves are fine and should not be rewritten — only the import sources, test runner scripts, and coverage configuration need to change. The developer should also leave notes on anything that might look like a problem but isn't.

## Output Specification

Produce:
- Updated versions of any test files that need import changes
- An updated `package.json` with corrected scripts
- A `migration-notes.md` explaining what changed and noting anything the team should be aware of regarding coverage tooling

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: package.json ===============
{
  "name": "@acme/parser",
  "version": "2.3.0",
  "type": "module",
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "vite-plus": "^1.0.0",
    "vitest": "^2.1.0",
    "@vitest/coverage-v8": "^2.1.0",
    "typescript": "^5.4.0"
  }
}

=============== FILE: src/parser.test.ts ===============
import { describe, it, expect, beforeEach } from 'vitest'
import { parse } from './parser.js'

describe('parse', () => {
  beforeEach(() => {
    // reset state
  })

  it('parses a simple expression', () => {
    expect(parse('1 + 2')).toEqual({ type: 'BinaryExpr', op: '+', left: 1, right: 2 })
  })

  it('handles nested parens', () => {
    expect(parse('(1 + 2) * 3')).toEqual({
      type: 'BinaryExpr',
      op: '*',
      left: { type: 'BinaryExpr', op: '+', left: 1, right: 2 },
      right: 3,
    })
  })

  it('throws on malformed input', () => {
    expect(() => parse('1 +')).toThrow('Unexpected end of input')
  })
})

=============== FILE: src/tokenizer.test.ts ===============
import { describe, it, expect } from 'vitest'
import { tokenize } from './tokenizer.js'

describe('tokenize', () => {
  it('tokenizes numbers', () => {
    expect(tokenize('42')).toEqual([{ type: 'NUMBER', value: '42' }])
  })

  it('tokenizes operators', () => {
    expect(tokenize('+')).toEqual([{ type: 'OPERATOR', value: '+' }])
  })

  it('tokenizes a full expression', () => {
    expect(tokenize('1 + 2')).toEqual([
      { type: 'NUMBER', value: '1' },
      { type: 'OPERATOR', value: '+' },
      { type: 'NUMBER', value: '2' },
    ])
  })
})

=============== FILE: README.md ===============
# @acme/parser

A fast expression parser for the Acme platform.

## Development

Install dependencies:

```sh
pnpm install
```

Run tests:

```sh
pnpm test
```

Run tests with coverage:

```sh
pnpm test:coverage
```
