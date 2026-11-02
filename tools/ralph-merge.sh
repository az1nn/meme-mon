#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT_DIR" ]]; then
  printf 'ralph-merge: run inside the repository\n' >&2
  exit 1
fi

usage() {
  printf '%s\n' \
    'Usage: tools/ralph-merge.sh <pull-request-number> [--allow-draft]' \
    'Fetches the exact PR head, validates it in an isolated worktree, then merges it into master.'
}

if [[ $# -lt 1 || "$1" == "--help" ]]; then
  usage
  exit 0
fi

PR_NUMBER="$1"
ALLOW_DRAFT=0
if [[ "${2:-}" == "--allow-draft" || "${RALPH_ALLOW_DRAFT_MERGE:-0}" == "1" ]]; then
  ALLOW_DRAFT=1
fi
if [[ ! "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  printf 'ralph-merge: invalid pull request number: %s\n' "$PR_NUMBER" >&2
  exit 1
fi
if (( ALLOW_DRAFT == 0 )); then
  printf 'ralph-merge: draft merges require --allow-draft or RALPH_ALLOW_DRAFT_MERGE=1\n' >&2
  exit 1
fi

cd "$ROOT_DIR"
if [[ "$(git branch --show-current)" != "master" ]]; then
  printf 'ralph-merge: current branch must be master\n' >&2
  exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  printf 'ralph-merge: master worktree must be clean\n' >&2
  exit 1
fi

git fetch origin master "refs/pull/${PR_NUMBER}/head:refs/remotes/origin/pr/${PR_NUMBER}"
PR_REF="refs/remotes/origin/pr/${PR_NUMBER}"
BASE_REF="refs/remotes/origin/master"
if ! git merge-base --is-ancestor "$BASE_REF" "$PR_REF"; then
  printf 'ralph-merge: PR #%s is not based on current origin/master; rebase/update it first\n' "$PR_NUMBER" >&2
  exit 1
fi

WORKTREE="$(mktemp -d "${TMPDIR:-/tmp}/mememom-ralph-merge-${PR_NUMBER}.XXXXXX")"
cleanup() {
  git worktree remove --force "$WORKTREE" >/dev/null 2>&1 || true
}
trap cleanup EXIT

git worktree add --detach "$WORKTREE" "$PR_REF" >/dev/null
printf 'ralph-merge: validating PR #%s at %s\n' "$PR_NUMBER" "$(git rev-parse "$PR_REF")"
(
  cd "$WORKTREE"
  git diff --check
  npm test
)

git merge --no-ff --no-edit "$PR_REF"
git push origin master
printf 'ralph-merge: PR #%s merged into origin/master\n' "$PR_NUMBER"
