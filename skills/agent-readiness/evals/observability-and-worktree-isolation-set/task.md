# Enabling Parallel Agent Work on a Python Flask API

## Problem/Feature Description

An engineering team runs three agents concurrently on the same Flask API repository, each working on different features in separate git worktrees. The setup is breaking down: agents are crashing each other's instances because they all start the server on port 5000, and when something goes wrong the agents have no machine-readable output they can query — they can only read console logs sprinkled with print statements that are difficult to parse programmatically. New worktrees also miss the repo's gitignored `.env.local`, which agents need for local-only development configuration.

You have been asked to fix both problems so agents can run reliably in parallel. Produce the updated application and the necessary scripts, along with documentation of the approach in `observability-notes.md`.

## Output Specification

Produce the following files:

1. `app.py` — Updated Flask application with improved observability: a way for agents to check whether the service is alive via HTTP, and machine-readable output for each request.

2. `worktree-start.sh` — Shell script that can be run inside any git worktree to start the Flask service without conflicting with other worktrees running on the same machine. The script must confirm the service is up before returning, and exit non-zero if the service fails to start.

3. `teardown.sh` — Shell script that stops the service started by worktree-start.sh.

4. `.gitignore` — Ignore local environment files and runtime artifacts.

5. `.worktreeinclude` — Narrowly include the gitignored local config file that managed Codex or Claude worktrees need.

6. `observability-notes.md` — Explanation of: (a) how an agent can programmatically query the health of the service, (b) how the startup script prevents port conflicts between worktrees, (c) how ignored local config is made available to managed worktrees, and (d) how to tear down after an agent finishes its task.

## Input Files

The following files represent the current state of the Flask API. Extract them before beginning.

=============== FILE: app.py ===============
from flask import Flask, request, jsonify
import datetime

app = Flask(__name__)

tasks = []

@app.route('/tasks', methods=['GET'])
def get_tasks():
    print(f"GET /tasks called at {datetime.datetime.now()}")
    return jsonify(tasks)

@app.route('/tasks', methods=['POST'])
def create_task():
    data = request.get_json()
    task = {'id': len(tasks) + 1, **data}
    tasks.append(task)
    print(f"Created task: {task}")
    return jsonify(task), 201

@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    global tasks
    tasks = [t for t in tasks if t['id'] != task_id]
    print(f"Deleted task {task_id}")
    return '', 204

if __name__ == '__main__':
    app.run(port=5000)

=============== FILE: requirements.txt ===============
flask>=3.0.0

=============== FILE: README.md ===============
# Task Manager API

Start with: python app.py
