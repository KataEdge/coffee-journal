---
name: github-flow
description: GitHub Flow branching strategy, topic branch rules, local test verification, and PR workflow for CoffeeJournal.
---

# GitHub Flow Guidelines

## Principles
1. `main` branch is always clean, passing tests, and deployable.
2. Every new feature, bug fix, or refactoring must be developed on a dedicated topic/feature branch created from `main`.
   - Naming convention: `feature/<feature-name>`, `fix/<bug-name>`, `refactor/<target>`.
3. Cycle during task implementation:
   - Check out `main`, pull latest: `git checkout main && git pull origin main`
   - Create feature branch: `git checkout -b feature/<feature-name>`
   - Build & test locally: `swift test`
   - Commit & push: `git add . && git commit -m "..." && git push -u origin feature/<feature-name>`
   - Open Pull Request (PR) for review and merging into `main`.
