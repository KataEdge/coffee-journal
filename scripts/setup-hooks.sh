#!/bin/bash
# Enable local Git hooks for CoffeeJournal repository

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not inside a git repository."
    exit 1
fi

chmod +x "$REPO_ROOT/.githooks/pre-commit"
git config core.hooksPath .githooks

echo "✅ Git hooks configured successfully! (core.hooksPath set to .githooks)"
echo "💡 Tip: Run 'brew install gitleaks' on macOS to enable local secret scanning before commits."
