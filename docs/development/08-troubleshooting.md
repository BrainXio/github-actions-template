# 08 – Troubleshooting

Quick fixes for the most common issues you’ll hit while using this GitHub Actions template.

## Setup & Environment

**“Reopen in Container” does nothing / setup never finishes**
→ Restart VS Code → try again
→ Check internet & Docker Desktop running
→ Manual: `make setup` in terminal (watch for errors)

**act says “Cannot find Docker image” or very slow**
→ First run downloads ~5–15 GB of images (normal, one-time)
→ Subsequent runs: seconds
→ Fix stuck download: `docker system prune -f` then `make test-push`

**pre-commit / lint fails on every commit**
→ Run locally: `pre-commit run --all-files`
→ Fix reported issues (whitespace, shellcheck, etc.)
→ Re-stage & commit

## Testing & act

**act: “no stages to run”**
→ Ensure `action.yml` exists in repo root
→ Check workflow path: `.github/workflows/ci.yml`
→ Verify job name & uses: `composite` in `action.yml`

**Outputs not visible / not set**
→ Confirm `echo "key=value" >> "$GITHUB_OUTPUT"` in script
→ Check case: `INPUT_XXX` (uppercase)
→ Test with `make test-dispatch` → look at terminal

**act fails with permission denied**
→ `chmod +x src/entrypoint.sh`
→ Re-run `make test-push`

## Releases & semantic-release

**Dry-run says “No release detected” forever**
→ No tags yet? → `git tag v0.0.0 && git push origin v0.0.0`
→ No `feat:`/`fix:`/`BREAKING CHANGE:` since last tag? → add one
→ Manual trigger: workflow_dispatch → check comment

**Release job runs but no tag/release created**
→ Check Actions logs for `release` job
→ Look for:
  - “No new release” → no qualifying commits
  - Permission error → repo settings → Actions → General → Workflow permissions → Read and write permissions
  - `.releaserc.json` syntax error

**Wrong version bump (e.g. patch instead of minor)**
→ Verify commit message uses correct type (`feat:` vs `fix:`)
→ Check for `BREAKING CHANGE:` footer or `feat!:` prefix

## Git & Workflow

**CI fails on commit message validation**
→ Must follow conventional commits format
→ Fix: amend commit → `git commit --amend -m "feat: correct message"`

**Branch won’t delete after merge**
→ Enable repo setting: “Automatically delete head branches”
→ Or manual: delete in GitHub UI after squash merge

**Still stuck?**
- Search Actions logs first (most answers are there)
- Run `make help` → try relevant commands locally
- Open issue on template repo with logs/screenshots

You now have the complete guide — happy building & shipping!
