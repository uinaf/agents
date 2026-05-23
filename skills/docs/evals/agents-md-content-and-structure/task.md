# Onboard a New AI Agent to the Payments Service

## Problem/Feature Description

The payments team at Meridian Corp has recently started using AI coding agents (Claude Code, OpenAI Codex) to help maintain their backend services. The agents keep going off-track: one recently overwrote a migration file because it couldn't find the correct setup steps; another spent 20 minutes exploring directory structure before writing a single line of code.

The team has identified that their `AGENTS.md` file is either missing or poorly written — it either dumps too much information (full architecture tours, every lint rule, directory tree dumps) or too little (no boot command, no test command). They need a well-structured `AGENTS.md` that gives agents exactly what they need to get oriented quickly without overwhelming them.

The codebase is a Node.js/TypeScript payments service. Currently the repo has a rough `AGENTS.md` that needs to be completely rewritten based on what agents actually need.

## Output Specification

Produce a replacement `AGENTS.md` file for this payments service repository. The file should orient an AI agent to the project efficiently.

Also produce a short `doc-report.md` explaining what you changed and why — noting any content you removed, what you kept, and the reasoning.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/AGENTS.md ===============
# Payments Service — Agent Guide

## Directory Structure

```
payments-service/
├── src/
│   ├── api/              # Express route handlers
│   │   ├── charges.ts
│   │   ├── refunds.ts
│   │   └── webhooks.ts
│   ├── db/
│   │   ├── migrations/   # Knex migration files (never edit manually)
│   │   └── models/       # Sequelize ORM models
│   ├── services/
│   │   ├── stripe.ts     # Stripe API wrapper
│   │   └── email.ts      # SendGrid email notifications
│   ├── utils/
│   │   ├── logger.ts
│   │   ├── errors.ts
│   │   └── validation.ts
│   └── index.ts          # App entry point
├── tests/
│   ├── unit/
│   └── integration/
├── docs/
│   ├── architecture.md
│   ├── api.md
│   └── deployment.md
├── scripts/
│   ├── bootstrap.sh      # Sets up dev environment (DEPRECATED, use setup.sh)
│   ├── setup.sh          # NEW: replaces bootstrap.sh
│   └── seed.sh           # Seed test database
├── package.json
└── .env.example
```

## Architecture Overview

The payments service is a REST API built on Express.js and TypeScript. It handles charge creation, refund processing, and webhook events from Stripe. Data is persisted in PostgreSQL using both Knex (for migrations) and Sequelize (for models — yes, we know this is inconsistent, it's a known tech debt item from Q2 2023 when we merged two teams).

The service uses a layered architecture: routes → controllers → services → data layer. External integrations (Stripe, SendGrid) are wrapped in service classes under `src/services/`. All Stripe webhooks go through `src/api/webhooks.ts`, which verifies the Stripe signature before processing.

Stripe webhook signature verification key is stored in `STRIPE_WEBHOOK_SECRET`. Never log this value.

## Getting Started

Prerequisites: Node.js 24.x LTS, PostgreSQL 15+, Docker (optional)

1. Install dependencies: `npm install`
2. Copy environment file: `cp .env.example .env`
3. Fill in the required values in `.env`
4. Run the setup script: `scripts/setup.sh`
5. Start the dev server: `npm run dev`

To run tests:
- Unit tests: `npm test`
- Integration tests: `npm run test:integration` (requires a running database)
- All tests with coverage: `npm run test:coverage`

## Coding Conventions

- **TypeScript strict mode** is enabled — no `any` types without a comment explaining why
- All new database queries must go through the ORM models, not raw SQL (except migrations)
- Use the custom logger (`src/utils/logger.ts`) for all logging — never use `console.log`
- Error handling: always use the custom `AppError` class from `src/utils/errors.ts`
- **Never commit** `.env` files or any secrets
- Branch naming: `feature/`, `fix/`, `chore/` prefixes required
- All PRs need at least one approval
- Commit messages should follow Conventional Commits format
- **IMPORTANT**: Never run `git push --force` on `main`

## API Documentation

The API follows REST conventions. All endpoints return JSON.

Authentication: Bearer token in the `Authorization` header. Token format: `JWT <token>`

Base URL: `/api/v1`

### Charges

`POST /api/v1/charges` — Create a new charge
Request body:
```json
{
  "amount": 1000,
  "currency": "usd",
  "customerId": "cust_123",
  "paymentMethodId": "pm_456",
  "description": "Order #789"
}
```
Response: 201 with charge object

`GET /api/v1/charges/:id` — Retrieve a charge
Response: 200 with charge object

`POST /api/v1/charges/:id/capture` — Capture an authorized charge
Response: 200 with updated charge

### Refunds

`POST /api/v1/refunds` — Create a refund
Request body: `{ "chargeId": "ch_123", "amount": 500 }`
Response: 201 with refund object

### Webhooks

`POST /api/v1/webhooks/stripe` — Stripe webhook endpoint
Headers: `stripe-signature` required

## Database

We use PostgreSQL 15. Connection string goes in `DATABASE_URL`.

Migration commands:
- Create: `npx knex migrate:make <name>`
- Run: `npx knex migrate:latest`
- Rollback: `npx knex migrate:rollback`

Seeding: `npm run seed` (runs `scripts/seed.sh`)

## Deployment

Deployed on AWS ECS via GitHub Actions. CI pipeline defined in `.github/workflows/`.

Deployment steps:
1. Merge to `main` triggers CI
2. CI runs tests and builds Docker image
3. Image pushed to ECR
4. ECS task definition updated and service redeployed

For manual deployments: see `docs/deployment.md`

## Troubleshooting

Common issues:
- "Cannot connect to database": Check DATABASE_URL and that PostgreSQL is running
- "Stripe signature verification failed": Check STRIPE_WEBHOOK_SECRET matches your Stripe dashboard
- "Module not found" errors after `git pull`: Run `npm install`

## Links

- Architecture: `docs/architecture.md`
- API Reference: `docs/api.md`
- Deployment Guide: `docs/deployment.md`

## Auto-Generated Section (DO NOT EDIT)
This section was automatically generated by our doc-gen tool on 2024-01-15.

| File | Lines | Last Modified |
|------|-------|---------------|
| src/api/charges.ts | 234 | 2024-03-01 |
| src/api/refunds.ts | 156 | 2024-02-14 |
| src/api/webhooks.ts | 89 | 2024-01-30 |
| src/services/stripe.ts | 312 | 2024-03-05 |
| src/db/migrations/ | 18 files | 2024-03-01 |
