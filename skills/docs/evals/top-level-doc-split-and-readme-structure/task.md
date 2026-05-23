# Restructure Documentation for an Open Source CLI Tool

## Problem/Feature Description

`grok-cli` is a command-line tool that parses and pretty-prints structured log files. It was written by a solo developer who crammed everything into a single `README.md` — install instructions, contributor setup, security contact, architecture notes, and usage examples are all mixed together. Now that the project is gaining traction and accepting outside contributions, the maintainer wants to split the documentation into proper separate files so that users, contributors, and security researchers can each find what they need quickly.

The current README.md is 280 lines and serves too many audiences at once: it explains how to install the tool, walks through the full source architecture, describes how to set up a dev environment, lists every lint rule enforced in CI, and buries the security contact at the very bottom. Contributors complain they can't find the setup steps; users give up before reaching the quickstart.

Your job is to restructure the documentation. The maintainer has no strong opinions about exact formatting — they just want each file to have a clear, single responsibility and for users to be able to get to their first successful `grok` command as quickly as possible.

## Output Specification

Produce the following files:
- `README.md` — restructured for end users
- `CONTRIBUTING.md` — for contributors
- `SECURITY.md` — for vulnerability reporters
- `doc-changes.md` — a brief summary of what moved where and why

Do not delete content — redistribute it. All information from the original README should appear in exactly one of the output files.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/README.md ===============
# grok-cli

grok-cli parses structured log files (JSON, logfmt, CEF) and pretty-prints them with filtering, highlighting, and aggregation support. It works with stdin or file inputs.

---

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Architecture](#architecture)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Running Tests](#running-tests)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)

---

## Installation

```bash
# Via Homebrew
brew install grok-cli

# Via npm
npm install -g grok-cli

# Build from source
git clone https://github.com/example/grok-cli.git
cd grok-cli
npm install
npm run build
npm link
```

## Usage

Parse a JSON log file:
```bash
grok parse app.log
```

Filter by level:
```bash
grok parse app.log --level error
```

Pipe from stdin:
```bash
cat app.log | grok parse -
```

Aggregate by field:
```bash
grok stats app.log --group-by service
```

Output formats: `--format pretty` (default), `--format json`, `--format csv`

## Architecture

grok-cli is structured as a pipeline:

```
Input → Parser → Filter → Formatter → Output
```

**Parser layer** (`src/parsers/`): one parser per format (JSON, logfmt, CEF). Each parser implements the `Parser` interface defined in `src/parsers/base.ts`. Parsers are selected automatically based on file extension or the `--format` flag.

**Filter layer** (`src/filters/`): composable filter predicates. Filters are combined with AND logic by default. The `--or` flag switches to OR logic.

**Formatter layer** (`src/formatters/`): renders the filtered output. `PrettyFormatter` uses chalk for colors; `JsonFormatter` and `CsvFormatter` are plain serializers.

**CLI layer** (`src/cli/`): Commander.js handles argument parsing and routes to the appropriate pipeline.

All errors go through `src/errors.ts`. The `GrokError` class carries an exit code so the process exits with the correct code for shell scripting.

## Development Setup

Prerequisites: Node.js 24.x LTS, npm 11+

1. Clone the repo:
   ```bash
   git clone https://github.com/example/grok-cli.git
   cd grok-cli
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run in development mode (auto-recompile):
   ```bash
   npm run dev
   ```

4. Link for local testing:
   ```bash
   npm link
   grok --version
   ```

## Coding Standards

All code must pass:
- `npm run lint` — ESLint with Airbnb config
- `npm run type-check` — TypeScript strict mode
- `npm run format:check` — Prettier

Rules enforced by CI:
- No `console.log` (use the logger in `src/logger.ts`)
- No `any` types without a `// eslint-disable` comment with justification
- Test files must be co-located with source files (`src/**/*.test.ts`)
- New parsers must implement `src/parsers/base.ts` interface
- All public API surfaces need JSDoc comments

## Running Tests

Unit tests (fast, no I/O):
```bash
npm test
```

Integration tests (reads real log files from `fixtures/`):
```bash
npm run test:integration
```

Full suite with coverage report:
```bash
npm run test:coverage
```

Tests must pass before any PR is merged. Coverage must not drop below 80%.

## Contributing

We welcome contributions! Please:
1. Fork the repo and create a branch (`feature/`, `fix/`, or `chore/` prefix)
2. Make your changes and add tests
3. Run the full test suite: `npm run test:coverage`
4. Run linting: `npm run lint && npm run type-check`
5. Open a PR with a clear description of the change

For significant features, open an issue first to discuss the design before investing implementation effort.

Code review: all PRs need at least one maintainer approval. We aim to review within 3 business days.

Release process: maintainers cut releases by tagging `v*` — this triggers the publish workflow.

## Security

**Do not open public GitHub issues for security vulnerabilities.**

To report a vulnerability, email security@example.com. Please include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact assessment

We aim to acknowledge reports within 48 hours and provide a fix or mitigation timeline within 7 days.

Supported versions: only the latest stable release receives security patches.

## License

MIT License — see [LICENSE](LICENSE) for details.
