#!/bin/bash
# PreToolUse guard for Edit/Write/NotebookEdit tools.
#
# Enforces the CLAUDE.md "Mandatory Pre-Work Check": never make file
# modifications directly on main. Blocks the tool call if the current
# branch is main, directing the agent to create a topic branch first.

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

branch="$(git branch --show-current 2>/dev/null || true)"

if [ "$branch" = "main" ]; then
    echo "❌ Editing directly on 'main' is blocked by CLAUDE.md's Mandatory Pre-Work Check. Create a topic branch first: git checkout -b feature/... or fix/..." >&2
    exit 2
fi

exit 0
