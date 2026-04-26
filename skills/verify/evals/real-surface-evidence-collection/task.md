# User API Verification

## Problem/Feature Description

A small backend team has just shipped a new user management REST API written in Python. The API handles listing users, fetching individual users, and creating new users. The engineer who built it has done some local testing but the team now needs an independent verification before the service is promoted to the staging environment.

The team lead wants concrete evidence — not just a read-through of the code — that the endpoints behave as expected under normal conditions and also under error conditions such as requesting a missing resource or sending malformed input. Previous incidents have been caused by untested error paths that appeared to work but returned unhelpful or incorrect responses.

## Output Specification

Produce a file named `verification-report.md` containing:

- The verdict on whether the API is ready to hand off for review (`ready for review`, `needs more work`, or `blocked`). The actual ship-or-not call belongs to `review`, not verify.
- A "Surfaces Exercised" section naming each endpoint tested
- A section with the exact commands you ran and the actual responses received
- A section covering any findings, each with severity, what the issue is, and the impact
- Any follow-up recommendations

The server script is already provided below. You should start it, run your verification against the live server, and then stop it when done. Use port 9127 to avoid conflicts.

## Input Files

The following file is provided as input. Extract it before beginning.

=============== FILE: inputs/server.py ===============
#!/usr/bin/env python3
"""Simple user management API server."""

import json
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

USERS = {
    "1": {"id": "1", "name": "Alice", "email": "alice@example.com"},
    "2": {"id": "2", "name": "Bob", "email": "bob@example.com"},
}

class APIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self._respond(200, {"status": "ok"})
        elif self.path.startswith("/users/"):
            user_id = self.path.split("/")[-1]
            user = USERS.get(user_id)
            if user:
                self._respond(200, user)
            else:
                self._respond(404, {"error": "not found"})
        elif self.path == "/users":
            self._respond(200, list(USERS.values()))
        else:
            self._respond(404, {"error": "not found"})

    def do_POST(self):
        if self.path == "/users":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            try:
                data = json.loads(body)
                new_id = str(len(USERS) + 1)
                user = {"id": new_id, "name": data["name"], "email": data["email"]}
                USERS[new_id] = user
                self._respond(201, user)
            except:
                self._respond(400, {"error": "bad request"})
        else:
            self._respond(404, {"error": "not found"})

    def _respond(self, status, data):
        body = json.dumps(data).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", len(body))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass  # suppress default logging

if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    server = HTTPServer(("localhost", port), APIHandler)
    print(f"Server running on port {port}", flush=True)
    server.serve_forever()
