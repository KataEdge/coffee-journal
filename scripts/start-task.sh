#!/bin/bash
set -e

# Worktree Task Starter for CoffeeJournal

RAW_NAME="$1"

if [ -z "$RAW_NAME" ]; then
  echo "❌ Error: Task/Feature name is required."
  echo "Usage: ./scripts/start-task.sh <task-name>"
  echo "Example: ./scripts/start-task.sh map-view"
  exit 1
fi

# Sanitize name: remove 'feature/' prefix if provided
FEATURE_SLUG="${RAW_NAME#feature/}"
BRANCH_NAME="feature/$FEATURE_SLUG"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "❌ Error: Not inside a git repository."
  exit 1
fi

PARENT_DIR="$(dirname "$REPO_ROOT")"
WORKTREE_DIR="$PARENT_DIR/coffee-journal-worktrees/$FEATURE_SLUG"

echo "🔍 Checking status for branch '$BRANCH_NAME'..."

# Check if worktree already exists
if git worktree list | grep -q "$WORKTREE_DIR"; then
  echo "ℹ️  Worktree already exists at: $WORKTREE_DIR"
  echo "👉 Navigate to worktree: cd $WORKTREE_DIR"
  exit 0
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "🌿 Branch '$BRANCH_NAME' already exists. Creating worktree for existing branch..."
  git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
else
  echo "✨ Fetching latest origin/main..."
  git fetch origin main 2>/dev/null || true
  
  echo "🚀 Creating new worktree at: $WORKTREE_DIR"
  git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME"
fi

# Copy untracked local secret files if present
echo "📋 Copying local configuration files to worktree..."
if [ -f "$REPO_ROOT/Secrets.plist" ]; then
  cp "$REPO_ROOT/Secrets.plist" "$WORKTREE_DIR/Secrets.plist"
  echo "  - Copied Secrets.plist"
fi

if [ -f "$REPO_ROOT/.env.local" ]; then
  cp "$REPO_ROOT/.env.local" "$WORKTREE_DIR/.env.local"
  echo "  - Copied .env.local"
fi

if [ -d "$REPO_ROOT/CoffeeJournal.xcodeproj" ]; then
  cp -R "$REPO_ROOT/CoffeeJournal.xcodeproj" "$WORKTREE_DIR/CoffeeJournal.xcodeproj"
  echo "  - Copied CoffeeJournal.xcodeproj"
fi


echo ""
echo "✅ Worktree initialized successfully!"
echo "📍 Location: $WORKTREE_DIR"
echo "🌿 Branch: $BRANCH_NAME"
echo ""
echo "To switch to your new worktree workspace:"
echo "  cd $WORKTREE_DIR"
