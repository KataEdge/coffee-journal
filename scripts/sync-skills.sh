#!/bin/bash
# sync-skills.sh
# ──────────────────────────────────────────────────────────────
# Keeps .agents/skills/ and .claude/skills/ in sync.
#
# Canonical source of truth: .agents/skills/
# .claude/skills/ contains symlinks → ../../.agents/skills/<name>
#
# When a NEW skill is found only in .claude/skills/ (created by
# Claude Code), it is moved to .agents/skills/ and replaced with
# a symlink so both tools can see it.
#
# Usage:
#   scripts/sync-skills.sh          # auto-fix (create missing links)
#   scripts/sync-skills.sh --check  # dry-run for CI / pre-commit
# ──────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.agents/skills"
CLAUDE_DIR="$REPO_ROOT/.claude/skills"

CHECK_ONLY=false
if [[ "${1:-}" == "--check" ]]; then
    CHECK_ONLY=true
fi

errors=0

# Ensure directories exist
mkdir -p "$AGENTS_DIR" "$CLAUDE_DIR"

# ── 1. .agents/skills → .claude/skills (create missing symlinks) ──
for skill in "$AGENTS_DIR"/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"

    if [ ! -e "$CLAUDE_DIR/$name" ]; then
        if $CHECK_ONLY; then
            echo "❌ Missing .claude/skills/$name symlink (exists in .agents/skills/)"
            errors=$((errors + 1))
        else
            ln -s "../../.agents/skills/$name" "$CLAUDE_DIR/$name"
            echo "✅ Created symlink: .claude/skills/$name → .agents/skills/$name"
        fi
    fi
done

# ── 2. .claude/skills → .agents/skills (adopt orphaned skills) ──
for skill in "$CLAUDE_DIR"/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"

    # Already a valid symlink pointing to .agents/skills — skip
    if [ -L "$CLAUDE_DIR/$name" ]; then
        target="$(readlink "$CLAUDE_DIR/$name")"
        if [[ "$target" == *".agents/skills/$name"* ]]; then
            continue
        fi
    fi

    # Real directory in .claude/skills but NOT in .agents/skills
    if [ ! -d "$AGENTS_DIR/$name" ]; then
        if $CHECK_ONLY; then
            echo "❌ Skill '$name' exists only in .claude/skills/ — needs adoption into .agents/skills/"
            errors=$((errors + 1))
        else
            echo "📦 Adopting .claude/skills/$name → .agents/skills/$name"
            mv "$CLAUDE_DIR/$name" "$AGENTS_DIR/$name"
            ln -s "../../.agents/skills/$name" "$CLAUDE_DIR/$name"
            echo "✅ Moved and symlinked: .claude/skills/$name → .agents/skills/$name"
        fi
    fi
done

# ── 3. Verify CLAUDE.md symlink ──
if [ ! -L "$REPO_ROOT/CLAUDE.md" ]; then
    if $CHECK_ONLY; then
        echo "❌ CLAUDE.md is not a symlink to .agents/AGENTS.md"
        errors=$((errors + 1))
    else
        echo "⚠️  CLAUDE.md is not a symlink. Creating: CLAUDE.md → .agents/AGENTS.md"
        ln -sf .agents/AGENTS.md "$REPO_ROOT/CLAUDE.md"
        echo "✅ Created symlink: CLAUDE.md → .agents/AGENTS.md"
    fi
fi

# ── Summary ──
if $CHECK_ONLY; then
    if [ $errors -gt 0 ]; then
        echo ""
        echo "Found $errors sync issue(s). Run 'scripts/sync-skills.sh' to fix."
        exit 1
    else
        echo "✅ All skills are in sync between .agents/ and .claude/"
        exit 0
    fi
else
    echo ""
    echo "✅ Sync complete."
fi
