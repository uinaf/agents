import type { ExperimentConfig } from '@vercel/agent-eval';

// Control: agent runs with NO rules/agents.md context.
const config: ExperimentConfig = {
  agent: 'vercel-ai-gateway/claude-code',
  model: 'sonnet',
  runs: 3,
  earlyExit: false,
  timeout: 600,
  copyFiles: 'changed',
};

export default config;
