# Enforce the No Direct useEffect Policy

## Problem/Feature Description

A React repository wants to enforce the no-direct-`useEffect` policy. It uses ESLint flat config and already has a shared `src/hooks/` directory. Add a policy that blocks direct `useEffect` imports and `React.useEffect(...)` namespace calls in application code, while allowing one narrow wrapper file for mount-only external synchronization.

Do not disable hooks linting globally. Do not block unrelated APIs like `useLayoutEffect` unless asked.

## Output Specification

Produce:

- `eslint.config.ts` with the policy
- `src/hooks/useMountEffect.ts` as the allowed escape hatch
- `policy-report.md` explaining the enforcement boundary and verification

## Input Files

=============== FILE: eslint.config.ts ===============
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import reactHooks from "eslint-plugin-react-hooks";

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    plugins: {
      "react-hooks": reactHooks,
    },
    rules: {
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",
    },
  },
);
=============== END FILE ===============
