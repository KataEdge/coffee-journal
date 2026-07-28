---
name: secret-management
description: Guidelines, best practices, and Gitleaks rules for managing secrets, passwords, API keys, and credentials in CoffeeJournal.
---

# Secret Management & Leak Prevention Guidelines

## Core Rules
1. **Never Commit Secrets**: Passwords, API keys, private tokens, S3 access credentials, and Supabase service keys MUST NEVER be committed to Git.
2. **Local Configuration**: Store secret values locally in `Secrets.plist` or `.env.local`. These files are listed in `.gitignore` and must remain unversioned.
3. **Sample Templates**: Provide dummy placeholder files such as `Secrets.sample.plist` for team members to set up their local environments.

## Automated Leak Detection
1. **Local Git Hook**:
   - Run `scripts/setup-hooks.sh` to configure `.githooks/pre-commit`.
   - Install Gitleaks on macOS via `brew install gitleaks`.
   - The pre-commit hook automatically scans staged files prior to `git commit`.
2. **CI Pipeline (GitHub Actions)**:
   - Every Push and Pull Request triggers the `gitleaks-security-scan` job in `.github/workflows/ci.yml`.
   - PR merges are blocked if Gitleaks detects any credential leaks in commit history.

## Handling False Positives & Custom Rules
- Custom rules and allowlists are managed in `.gitleaks.toml`.
- Sample template files (`*.sample.*`) and placeholder strings (e.g. `YOUR_SUPABASE_ANON_KEY`) are registered under `[allowlist]` in `.gitleaks.toml`.
