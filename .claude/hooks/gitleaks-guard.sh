#!/bin/bash
# PreToolUse guard for the Bash tool.
#
# Enforces the CLAUDE.md rule "verify local/CI secret scanning passes
# before pushing PRs" at the harness level, independent of whether the
# repo's native .githooks/pre-commit has been installed (scripts/setup-hooks.sh)
# or whether a commit is made with --no-verify.
#
# Only acts on `git commit` / `git push` Bash invocations; everything
# else is approved immediately.

set -euo pipefail

input="$(cat)"
command="$(python3 -c 'import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    data = {}
print(data.get("tool_input", {}).get("command", ""))' <<<"$input" 2>/dev/null || true)"

if ! printf '%s' "$command" | grep -Eq '(^|[;&|]|&&)\s*git\s+(commit|push)\b'; then
    exit 0
fi

if ! command -v gitleaks >/dev/null 2>&1; then
    echo "⚠️  gitleaks is not installed — skipping local secret scan for '$command'. Install via 'brew install gitleaks'." >&2
    exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

if printf '%s' "$command" | grep -Eq '\bgit\s+commit\b'; then
    if ! gitleaks protect --staged --redact -v; then
        echo "❌ Gitleaks detected sensitive credentials in staged changes. Remove secrets or update .gitleaks.toml before committing." >&2
        exit 2
    fi
else
    if ! gitleaks detect --redact -v; then
        echo "❌ Gitleaks detected sensitive credentials in commit history. Resolve before pushing." >&2
        exit 2
    fi
fi

exit 0
