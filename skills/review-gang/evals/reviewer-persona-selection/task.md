# Code Review: Authentication Middleware Refactor

## Problem/Feature Description

A backend team has just merged a pull request that refactors the authentication middleware for their Node.js API. The change reorganizes how JWT tokens are verified and replaces a hand-rolled validation utility with a shared library, and it also tidies up some old compatibility shims that were left over from a previous auth provider migration. The diff introduces a new `AuthToken` TypeScript interface to replace several loosely-typed string-based checks, and it touches the error handling paths for expired tokens, malformed payloads, and missing authorization headers.

You have been asked to review this pull request on behalf of a senior engineer who is on vacation. The team wants a clear verdict on whether this change is safe to ship before it goes to production later today.

## Output Specification

Produce a written review report saved to `review-report.md`. The report should cover all the concerns relevant to this change and give the team a clear answer on what to do next.

The repository is provided inline below. Use `git log` and `git diff` to inspect the change.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: repo/AGENTS.md ===============
# Agent Rules

- All authentication errors must return HTTP 401 with a JSON body containing `error` and `message` fields.
- Never log raw JWT payloads.
- Use `zod` for all runtime validation of external inputs.
- Integration tests must cover all authentication failure paths.

=============== FILE: repo/src/auth/middleware.ts ===============
import jwt from 'jsonwebtoken';
import { z } from 'zod';

const TokenPayloadSchema = z.object({
  sub: z.string(),
  role: z.enum(['admin', 'user', 'readonly']),
  exp: z.number(),
});

export type AuthToken = z.infer<typeof TokenPayloadSchema>;

export function authenticate(req: any, res: any, next: any) {
  const header = req.headers['authorization'];
  if (!header) {
    return res.status(401).json({ error: 'missing_auth', message: 'Authorization header required' });
  }

  const token = header.replace('Bearer ', '');
  try {
    const raw = jwt.verify(token, process.env.JWT_SECRET!);
    const parsed = TokenPayloadSchema.safeParse(raw);
    if (!parsed.success) {
      return res.status(401).json({ error: 'invalid_token', message: 'Token payload does not match expected shape' });
    }
    req.user = parsed.data;
    next();
  } catch (e: any) {
    return res.status(401).json({ error: 'auth_failed', message: e.message });
  }
}

=============== FILE: repo/src/auth/middleware.old.ts ===============
// LEGACY FILE - kept for reference, no longer imported anywhere
import jwt from 'jsonwebtoken';

export function legacyAuthenticate(req: any, res: any, next: any) {
  const token = req.headers['x-auth-token'];
  if (!token) return next();  // silently skip if missing
  try {
    const decoded: any = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded;
    next();
  } catch {
    next(); // swallow error, let downstream decide
  }
}

=============== FILE: repo/src/auth/index.ts ===============
export { authenticate, AuthToken } from './middleware';
// legacyAuthenticate intentionally not re-exported

=============== FILE: repo/tests/auth.test.ts ===============
import { authenticate } from '../src/auth/middleware';
import jwt from 'jsonwebtoken';

const SECRET = 'test-secret';
process.env.JWT_SECRET = SECRET;

function makeReq(token?: string) {
  return { headers: { authorization: token ? `Bearer ${token}` : undefined } };
}
function makeRes() {
  const res: any = {};
  res.status = (code: number) => { res.statusCode = code; return res; };
  res.json = (body: any) => { res.body = body; return res; };
  return res;
}

test('rejects missing header', () => {
  const res = makeRes();
  authenticate(makeReq(), res, () => {});
  expect(res.statusCode).toBe(401);
});

test('accepts valid token', () => {
  const token = jwt.sign({ sub: 'user1', role: 'user', exp: Math.floor(Date.now()/1000) + 3600 }, SECRET);
  const res = makeRes();
  let called = false;
  authenticate(makeReq(token), res, () => { called = true; });
  expect(called).toBe(true);
});

=============== FILE: repo/package.json ===============
{
  "name": "api-service",
  "dependencies": {
    "jsonwebtoken": "^9.0.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "@types/jest": "^29.0.0",
    "typescript": "^5.0.0"
  }
}

=============== FILE: repo/.git-placeholder ===============
The PR being reviewed introduced:
- repo/src/auth/middleware.ts (new version replacing hand-rolled checks)
- AuthToken type via zod schema (replaces old string-based checks)
- repo/src/auth/middleware.old.ts was retained but no longer imported
- repo/src/auth/index.ts updated to not re-export legacy function
The base branch did not have the zod schema or the AuthToken type.
