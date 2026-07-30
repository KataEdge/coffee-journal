# Workspace Development Rules (Coffee Journal)

## GitHub Flow Strategy
- Always develop new features, bug fixes, or refactoring in a separate topic branch (e.g. `feature/...`, `fix/...`).
- Ensure all unit tests (`swift test`) pass before pushing and opening a Pull Request (PR) to `main`.
- Maintain `main` as the stable, always-green branch.

## Token Optimization & Efficiency
- **Subagent Delegation**: Delegate broad codebase searches, extensive file reading, and investigation tasks to the `research` subagent to prevent bloating the main conversation context.
- **Efficient Log Extraction**: When inspecting command outputs or build failures, filter and extract only the relevant error lines and stack traces rather than outputting large log files into the conversation.
## Secret Management & Security Policy
- **Credential Protection**: Never commit API keys, passwords, or tokens. Keep secret credentials in unversioned local files (`Secrets.plist`, `.env.local`).
- **Gitleaks Scanning**: Maintain `.gitleaks.toml` rules and verify local/CI secret scanning passes before pushing PRs.

## Multi-Session & Git Worktree Strategy
- **Session & Branch Isolation**:
  - Always run parallel AI sessions (Claude Code, Antigravity, etc.) in dedicated topic branches and separate Git Worktrees to prevent source code collisions and dirty git states.
- **Worktree Directory Standard**:
  - Create worktrees in the parent directory using: `../coffee-journal-worktrees/<feature-name>` (or `../coffee-journal-<feature-name>`).
  - Command example: `git worktree add ../coffee-journal-worktrees/feature-map-view -b feature/map-view`
- **Pre-Session Safety Verification**:
  - At the start of a session, check `git branch`, `git worktree list`, and `git status` to verify that the workspace is operating in an isolated, clean topic branch.

