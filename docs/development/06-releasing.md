# 06 – Releasing a New Version

Fully automated releases using **semantic-release** — driven by conventional commits, zero manual tagging after setup.

## How it works

1. semantic-release scans commits since last tag
2. Decides version bump based on commit types:
   - `fix:` → **patch** (v1.2.3 → v1.2.4)
   - `feat:` → **minor** (v1.2.3 → v1.3.0)
   - `BREAKING CHANGE:` footer or `feat!:` → **major** (v1.2.3 → v2.0.0)
   - `docs:`, `chore:`, `ci:`, etc. → **no bump**
3. Generates changelog grouped by type
4. Creates Git tag + GitHub release with changelog body
5. Pushes tag back to repository

Dry-run runs on every PR/push → shows preview comment: “Next version would be v1.3.0 if merged”

## First release setup (one-time only)

If no tags exist yet (fresh template/fork):

1. Create baseline tag:
```bash
git tag -a v0.0.0 -m "Initial baseline – starting point for semantic releases"
git push origin v0.0.0
```

2. Add at least one releasable commit:
```bash
git commit --allow-empty -m "feat: prepare first automated release"
git push
```

3. Merge to `main` (via PR)
   → `release` job runs automatically → creates v0.1.0 + release notes

**Alternative: start at v1.0.0**
```bash
git tag -a v1.0.0 -m "First public release"
git push origin v1.0.0
```

Future changes bump from there.

## Normal release flow (after first tag)

1. Make changes with conventional commits (`feat:`, `fix:`, etc.)
2. Open PR → see dry-run comment in PR (“Next version: v1.3.0…”)
3. Review → **squash merge** to `main`
4. CI `release` job runs → creates tag + GitHub release automatically
   → no manual steps needed

## Common scenarios

**I want a patch release**
→ Merge a PR with at least one `fix:` commit → gets vX.Y.Z → vX.Y.(Z+1)

**I want no version bump**
→ Use `docs:`, `chore:`, `ci:`, `test:`, `style:`, `refactor:` prefixes only

**Dry-run says “No release” / “No new version”**
→ Check `git tag -l` — no tag? → create v0.0.0
→ No `feat:`/`fix:`/`BREAKING CHANGE:` since last tag? → add one

**Release job failed**
→ Check Actions logs for `release` job
→ Common causes: missing `GITHUB_TOKEN` permissions (`contents: write`), invalid commit messages, or syntax error in `.releaserc.json`

**Want to skip release for a commit**
→ Use non-bumping type (`chore:`, `docs:`, etc.)
→ Or add footer `skip-release: true` (if configured)

## Customization options

Edit `.releaserc.json` to change:
- Version scheme (semver, calver, etc.)
- Changelog sections / wording
- Additional publish targets (npm, Docker Hub — add plugins + secrets)

Next → [07 – Common Scenarios & Recipes](07-common-scenarios.md)
