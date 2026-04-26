import type { ExperimentConfig } from '@vercel/agent-eval';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

// Treatment 2: agent reads the pre-trim 154-line rules/agents.md (from commit 5e14688).
const rulesContent = readFileSync(
  join(process.cwd(), 'fixtures', 'rules-original.md'),
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
