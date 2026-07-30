#!/bin/bash
# install-hooks.sh
# ──────────────────────────────────────────────────────────────
# Installs git hooks and syncs skills.
# Run once after cloning or in a new worktree.
# ──────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── 1. Configure git to use .githooks/ ──
echo "🔧 Setting core.hooksPath to .githooks/"
git -C "$REPO_ROOT" config core.hooksPath .githooks
chmod +x "$REPO_ROOT/.githooks/"*

# ── 2. Sync skills ──
echo ""
"$REPO_ROOT/scripts/sync-skills.sh"

echo ""
echo "🎉 Setup complete! Pre-commit hooks and skills sync are active."
