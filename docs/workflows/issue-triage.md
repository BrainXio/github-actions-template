# Issue Triage Workflow (issue-triage.yml)

## Introduction and Purpose

The `issue-triage.yml` workflow automates initial handling of new issues to improve contributor experience and maintainer efficiency. It runs only on issue creation, adding structure without overwhelming the process.

This is an optional feature in the template — disabled by default to keep things minimal. It's a great example of event-specific automation using GitHub Actions.

## Triggers

- **issues**: On `opened` or `reopened` events only (ignores edits, labels, comments, etc.).
- No other events — keeps it focused and fast.

## Jobs and Workings

The workflow has a single job: `triage`.

- **Purpose**: Quick first-touch automation to acknowledge and categorize new issues.
- **When it runs**: On issue open/reopen.
- **Steps and workings**:
  - Checkout the repo (required for actions).
  - Add label "investigate" using `github-script` (checks if label already exists to avoid duplicates).
  - Post a welcome comment using `create-or-update-comment` (friendly thanks + guidance).
- **Outcomes**:
  - New issue gets "investigate" label → signals "needs review" to maintainers.
  - Comment posted: Thanks the author, explains the label, encourages more details, links to guides.
  - Success: Issue is triaged in seconds, contributor feels welcomed.
  - Failure: Rare (e.g., API limit) — logs in Actions tab, no harm to repo.

## Level of Automation

- **Overall**: Medium — handles 70–80% of initial triage (label + comment), but leaves manual review for details.
- **What requires human input**: Removing/replacing the label, responding to contributor follow-ups, closing/resolving the issue.
- **Extensibility**: Easy to add auto-assign (e.g. to repo owner), label based on keywords, or integrate with bots.

## When No Tags Exist Yet

This workflow doesn't depend on tags or releases — it's event-based on issues only.
No setup needed; it works immediately once enabled.
If no "investigate" label exists in your repo:
- Create it manually (Repo → Issues → Labels → New label) — color like #FFD700 (yellow) for "pending review".
- Or the workflow will fail silently (check Actions logs).

For enabling:
- Remove `if: false` from the job (if present).
- Customize the label name/comment text to fit your project.
- Test by opening a dummy issue — see the label/comment appear.

For troubleshooting:
- If comment fails: Check `issues: write` permission.
- Logs in Actions tab under "Issue Triage".

This workflow enhances community engagement without adding complexity to the core template.
