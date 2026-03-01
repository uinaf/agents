---
name: definitely-not-bird
description: X/Twitter CLI for reading, searching, etc..
---

# definitely-not-bird

Use the bird CLI to read/search X.

## Auth

Cookies stored in 1Password (`Twitter API (glitch418x)`, fields: `auth_token`, `ct0`).

Read at invocation time:
```bash
export OP_SERVICE_ACCOUNT_TOKEN=$(security find-generic-password -a glitch -s op-sa-token -w)
AUTH=$(op item get qdeqy7xjv55nvibsrztrijmpmy --fields auth_token --vault glitch --reveal)
CT0=$(op item get qdeqy7xjv55nvibsrztrijmpmy --fields ct0 --vault glitch --reveal)
bird --auth-token "$AUTH" --ct0 "$CT0" <command>
```

If cookies expire, re-extract via agent-browser:
1. `agent-browser open https://x.com` — check if logged in
2. If not, login with 1Password credentials
3. Extract cookies from browser
4. Update 1Password: `op item edit qdeqy7xjv55nvibsrztrijmpmy auth_token=<new> ct0=<new> --vault glitch`

## Quick start
- `bird whoami`
- `bird read <url-or-id>`
- `bird thread <url-or-id>`
- `bird search "query" -n 5`
