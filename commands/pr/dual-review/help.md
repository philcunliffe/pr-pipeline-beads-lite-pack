Dual-agent PR review for outgoing PRs. Runs Claude's `/code-review-quiet`
skill (5-Sonnet parallel scan + Haiku confidence scoring) and Codex's
review prompt in parallel against the same PR, then composes a risk
capstone via `mol-pr-blast-radius` to classify the change surface, and
computes a single mechanical verdict from the union of all signals.

This dispatches a coding agent to a rig with the `mol-pr-dual-review`
formula. The agent fetches the PR diff, runs both reviewers, generates
a risk capstone, and writes reports to the city
`.gc/pr-pipeline/reviews/pr-<N>/` directory. **No GitHub comment is
posted.** Any maintainer-visible comment is the caller's responsibility.

Sibling: `pr review` runs only the 11-category scorecard (single-agent).
`pr dual-review` is the consolidated dual-agent + risk-capstone
replacement, drop-in compatible with the same `verdict:` notes contract.

Usage:
  gc <binding> pr dual-review <pr-number-or-url> [flags]

Arguments:
  <pr>                PR number (in current repo) or GitHub PR URL.

Flags:
  --rig <name>        Rig to review inside (defaults to $GC_RIG).
  --agent <name>      Worker agent name (default:
                      "gastown-beads-lite.polecat").

Examples:
  gc <binding> pr dual-review 1234 --rig api-server
  gc <binding> pr dual-review https://github.com/owner/repo/pull/1234

Direct sling (skip this command):
  gc sling api-server/gastown-beads-lite.polecat mol-pr-dual-review --formula --var pr=1234

Output:
  Per-reviewer reports + combined index at
  ${GC_CITY_PATH}/.gc/pr-pipeline/reviews/pr-<N>/ when GC_CITY_PATH is
  available; otherwise <repo-root>/.gc/pr-pipeline. Files written:
    codex.md         Codex reviewer output (PTY-captured)
    claude.md        Claude /code-review-quiet structured comment body
    risk.md          Risk capstone: cross-reference of findings vs
                     blast-radius surfaces, with risk_class
    dual-review.md   Combined index linking the three reports
  Root-bead notes record `verdict:` (request_changes | approve)
  and `risk_class:` (low | medium | high).

Decision policy (mechanical, union semantics):
  Any blocker/critical finding OR risk_class=high  → verdict request_changes
  Majors in cat 1-8 OR (risk_class=medium AND any) → verdict request_changes
  Otherwise (only minors / nits / no findings)     → verdict approve
