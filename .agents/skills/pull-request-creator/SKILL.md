---
name: pull-request-creator
description: Guidelines, pre-checks, PR description templates, and GitHub CLI commands to create Pull Requests (PRs) merging topic branches into main for CoffeeJournal.
---

# Pull Request Creation Skill

Use this skill when preparing, validating, and submitting a Pull Request (PR) to merge a topic branch (`feature/...`, `fix/...`, `refactor/...`) into `main`.

---

## 1. Pre-Submission Check Sequence

Before creating a PR, run the following verification steps:

1. **Verify Branch**:
   Ensure you are **not** on `main`.
   ```bash
   git branch --show-current
   ```
2. **Check Working Directory**:
   Ensure all changes are committed.
   ```bash
   git status --porcelain
   ```
3. **Run Unit Tests**:
   Ensure all tests pass locally.
   ```bash
   swift test
   ```
4. **Push Topic Branch**:
   Ensure the latest commits are pushed to remote.
   ```bash
   git push -u origin HEAD
   ```

---

## 2. PR Title & Description Guidelines

### Title Format
Use clear Conventional Commit prefixes:
- `feat: <summary>` for new features
- `fix: <summary>` for bug fixes
- `refactor: <summary>` for refactoring
- `docs: <summary>` for documentation updates

### PR Body Template
Structure the PR body clearly:

```markdown
## 概要 (Summary)
- [Briefly describe the purpose of this PR]

## 主な変更点 (Key Changes)
- [Bullet points of files/logic modified]

## 動作確認 (Verification & Tests)
- [x] Unit tests passed (`swift test`)
- [ ] Manual UI verification (if applicable)

## 補足事項 (Notes)
- [Any additional notes or dependencies]
```

---

## 3. Creating the PR via GitHub CLI (`gh`)

Use `gh pr create` with the template:

```bash
gh pr create \
  --base main \
  --title "<prefix>: <short description>" \
  --body "## 概要 (Summary)
...
## 主な変更点 (Key Changes)
...
## 動作確認 (Verification & Tests)
- [x] Unit tests passed (\`swift test\`)
"
```

*If `gh` CLI is not logged in or available, present the draft title, body, and push URL to the user so they can submit the PR on GitHub.*
