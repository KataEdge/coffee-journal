# Workspace Development Rules (Coffee Journal)

## GitHub Flow Strategy
- Always develop new features, bug fixes, or refactoring in a separate topic branch (e.g. `feature/...`, `fix/...`).
- Ensure all unit tests (`swift test`) pass before pushing and opening a Pull Request (PR) to `main`.
- Maintain `main` as the stable, always-green branch.
- **Mandatory Pre-Work Check**: Before making ANY file modifications (creating, editing, or deleting files), the agent MUST:
  1. Run `git branch --show-current` and `git status` to verify the current state.
  2. If on `main`, create a topic branch (`git checkout -b feature/...` or `fix/...`) BEFORE touching any files.
  3. Never make code or config changes directly on `main` — not even "small" or "trivial" ones.

## Token Optimization & Efficiency
- **Subagent Delegation**: Delegate broad codebase searches, extensive file reading, and investigation tasks to the `research` subagent to prevent bloating the main conversation context.
- **Efficient Log Extraction**: When inspecting command outputs or build failures, filter and extract only the relevant error lines and stack traces rather than outputting large log files into the conversation.
## Secret Management & Security Policy
- **Credential Protection**: Never commit API keys, passwords, or tokens. Keep secret credentials in unversioned local files (`Secrets.plist`, `.env.local`).
- **Gitleaks Scanning**: Maintain `.gitleaks.toml` rules and verify local/CI secret scanning passes before pushing PRs.

## Database Schema & Migration Policy
- **No Undocumented Schema Changes**: Any change to the live Supabase schema (tables, columns, `CHECK`/`FOREIGN KEY`/`UNIQUE` constraints, RLS policies, indexes, functions) — whether applied via the Supabase SQL Editor, `psql`, or any other direct connection — MUST be captured as a `.sql` file under `docs/migrations/` (named `YYYYMMDD_description.sql`) in the SAME session/PR that applies it. Update `.agents/skills/supabase-schema/SKILL.md` too if the change affects the documented table shape.
- **Why**: A prior scale-widening change (1-5 → 1-10 taste ratings) was applied to Swift code but never migrated on the live DB, and no migration file existed to catch the drift — it silently broke saves in production until debugged live. See `docs/migrations/20260731_widen_tasting_notes_scale_to_10.sql` for the recovered record.
- **Order of operations**: prefer writing the migration file *first*, then applying it, over applying-then-documenting — this makes the file the actual source of truth instead of an afterthought.

## Multi-Session & Git Worktree Strategy
- **Session & Branch Isolation**:
  - Always run parallel AI sessions (Claude Code, Antigravity, etc.) in dedicated topic branches and separate Git Worktrees to prevent source code collisions and dirty git states.
- **Worktree Directory Standard**:
  - Create worktrees in the parent directory using: `../coffee-journal-worktrees/<feature-name>` (or `../coffee-journal-<feature-name>`).
  - Command example: `git worktree add ../coffee-journal-worktrees/feature-map-view -b feature/map-view`
- **Pre-Session Safety Verification**:
  - At the start of a session, check `git branch`, `git worktree list`, and `git status` to verify that the workspace is operating in an isolated, clean topic branch.
- **Duplicate Work Prevention**:
  - Before starting a new task, run `git branch -a` and `gh pr list --state all` to confirm another session/agent has not already created a branch or PR for the same work. Isolation alone (worktrees) does not prevent two sessions from independently picking the same feature — this check is what does.
- **Untracked Local Files in New Worktrees**:
  - `git worktree add` only checks out tracked files. Gitignored local files required to build/test (`Secrets.plist`, `.env.local`) will NOT exist in a new worktree and must be copied in manually before running `swift test`, e.g. `cp Secrets.plist ../coffee-journal-worktrees/<feature-name>/Secrets.plist`.
- **Worktree Cleanup**:
  - After a branch is merged, remove its worktree before deleting the branch: `git worktree remove ../coffee-journal-worktrees/<feature-name>` (a branch checked out in a worktree cannot be deleted with `git branch -d`). Run `git worktree prune` periodically to clear stale entries.

## Cross-Tool Skills Sync (Antigravity ↔ Claude Code)
- **Canonical Source**: `.agents/skills/` is the single source of truth for all skills. `.claude/skills/` contains **symlinks** pointing to `.agents/skills/`.
- **Creating a New Skill**: Always create skills in `.agents/skills/<skill-name>/SKILL.md`, then run `scripts/sync-skills.sh` to create the corresponding `.claude/skills/` symlink.
- **Pre-Commit Guard**: The `.githooks/pre-commit` hook automatically checks for missing symlinks and blocks commits if skills are out of sync. Run `scripts/sync-skills.sh` to fix.
- **CLAUDE.md**: `CLAUDE.md` at the repo root is a symlink to `.agents/AGENTS.md`. Edit `.agents/AGENTS.md` directly; changes are reflected in both tools.
- **After Cloning / New Worktree**: Run `scripts/install-hooks.sh` to set up git hooks and sync skills.
