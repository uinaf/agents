# Skill Portfolio Review: Activation and Routing Problems

## Problem/Feature Description

A product team has three skills that have been underperforming. Users keep triggering the wrong skill, or no skill at all. The team's hypothesis is that the skill names and descriptions are too vague and that the boundary between overlapping skills is never stated, causing the model to half-trigger all three whenever any related request comes in.

Additionally, the team recently added a fourth skill, `data-pipeline`, and wants to know whether its description is written in a style consistent with the others. They also noticed that a pull request last week added some application code review guidance directly to the `data-pipeline` skill, which they suspect is out of place.

Your task is to audit all four skills for discovery and boundary clarity, identify which ones are most at risk of poor activation, and write a report with concrete rewrite suggestions for the names and descriptions. Also flag content that is outside the owning package and describe the required review capability or repository-owned guidance without inventing another skill.

## Output Specification

Produce:

- `audit-report.md` — one section per skill, each including: the Tessl command run, the score, a discovery assessment, a boundary assessment, the current description's weaknesses, and a proposed replacement description
- `audit-log.sh` — shell commands run in execution order
- `rewrite-suggestions.md` — the four proposed replacement `name` + `description` fields in frontmatter format, ready to copy-paste

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: skills/notifier/SKILL.md ===============
---
name: notifier
description: Sends notifications.
---

# Notifier

Use this skill to send notifications. It can send emails, Slack messages, and webhooks.

## Workflow

1. Identify what needs to be sent
2. Choose the channel
3. Send it

=============== FILE: skills/alerter/SKILL.md ===============
---
name: alerter
description: Handles alerts and notifications for the platform.
---

# Alerter

This skill handles alerts. Use it when something goes wrong and you need to alert someone. It can also send routine notifications if needed.

## Workflow

1. Detect the alert condition
2. Route to the right channel
3. Escalate if unacknowledged after 5 minutes

=============== FILE: skills/comms-router/SKILL.md ===============
---
name: comms-router
description: Routes communications.
---

# Comms Router

Routes outbound communications to the right channel. Works with email, Slack, PagerDuty, and webhooks.

## Workflow

1. Accept the message payload
2. Look up routing rules
3. Dispatch

=============== FILE: skills/data-pipeline/SKILL.md ===============
---
name: data-pipeline
description: It's a skill for data pipelines.
---

# Data Pipeline

Use this skill for data pipeline tasks. It orchestrates ETL jobs, monitors pipeline health, and triggers backfills.

## Code Review Guidance

When reviewing any Python application code in the repo:
- Check for PEP 8 compliance
- Ensure type hints are present on all public functions
- Verify unit test coverage is above 80%

## Workflow

1. Identify the pipeline to act on
2. Check current health status
3. Trigger the required operation (run, backfill, pause)
4. Monitor until completion
