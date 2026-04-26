import type { ExperimentConfig } from '@vercel/agent-eval';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

// Treatment 1: agent reads the trimmed (current) rules/agents.md.
const rulesContent = readFileSync(
  join(process.cwd(), '..', 'rules', 'agents.md'),
  'utf-8',
);

const config: ExperimentConfig = {
  agent: 'vercel-ai-gateway/claude-code',
  model: 'sonnet',
  runs: 3,
  earlyExit: false,
  timeout: 600,
  copyFiles: 'changed',
  setup: async (sandbox) => {
    await sandbox.writeFiles({ 'CLAUDE.md': rulesContent });
  },
};

export default config;
