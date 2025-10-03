#!/usr/bin/env bash
#
# Fetches the AmpedAIWeb repository into a local directory. Intended for use
# in cron jobs where you want to keep a local clone up to date without
# interactive maintenance.
#
# Usage:
#   ./pull_repo.sh [target_directory]
#
# Environment variables:
#   REPO_URL - Override the repository URL to clone. Defaults to the public GitHub repo.
#   BRANCH   - Branch to checkout/reset to. Defaults to "main".
#
# When run without arguments the script keeps the repository in the directory
# that contains the script. If the script lives inside a directory named
# "scripts" (as it does in this repository), the parent directory is used so the
# repository root stays one level up. This makes it convenient for cron jobs
# that should self-update.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TARGET="$SCRIPT_DIR"
if [[ "$(basename "$SCRIPT_DIR")" == "scripts" ]]; then
  DEFAULT_TARGET="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

REPO_URL="${REPO_URL:-https://github.com/trogy/AmpedAIWeb.git}"
TARGET_DIR="${1:-$DEFAULT_TARGET}"
BRANCH="${BRANCH:-main}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

fatal() {
  log "ERROR: $*"
  exit 1
}

[[ -n "$REPO_URL" ]] || fatal "REPO_URL must be provided via environment variable or default"

command -v git >/dev/null 2>&1 || fatal "git is not installed or not in PATH"

mkdir -p "$TARGET_DIR"

if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    fatal "$TARGET_DIR exists but is not a git repository. Move or remove the contents before running this script."
  fi

  log "Cloning repository from $REPO_URL into $TARGET_DIR"
  git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$TARGET_DIR" >/dev/null \
    || fatal "Failed to clone $REPO_URL into $TARGET_DIR"

  log "Repository ready at $TARGET_DIR on branch $BRANCH"
  exit 0
fi

CURRENT_REMOTE="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"
if [[ -n "$CURRENT_REMOTE" ]]; then
  if [[ "$CURRENT_REMOTE" != "$REPO_URL" ]]; then
    log "Updating origin remote from $CURRENT_REMOTE to $REPO_URL"
    git -C "$TARGET_DIR" remote set-url origin "$REPO_URL" \
      || fatal "Failed to update origin remote"
  fi
else
  log "Setting origin remote to $REPO_URL"
  git -C "$TARGET_DIR" remote add origin "$REPO_URL" \
    || fatal "Failed to add origin remote"
fi

git -C "$TARGET_DIR" fetch --prune --tags origin \
  || fatal "Failed to fetch updates from $REPO_URL"

if ! git -C "$TARGET_DIR" rev-parse --verify --quiet "origin/$BRANCH"; then
  fatal "Branch $BRANCH does not exist on origin"
fi

if git -C "$TARGET_DIR" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git -C "$TARGET_DIR" checkout -f "$BRANCH" >/dev/null \
    || fatal "Failed to checkout branch $BRANCH"
else
  log "Creating local branch $BRANCH from origin/$BRANCH"
  git -C "$TARGET_DIR" branch -f "$BRANCH" "origin/$BRANCH" >/dev/null \
    || fatal "Failed to create branch $BRANCH"
  git -C "$TARGET_DIR" checkout -f "$BRANCH" >/dev/null \
    || fatal "Failed to switch to branch $BRANCH"
fi

git -C "$TARGET_DIR" reset --hard "origin/$BRANCH" \
  || fatal "Failed to reset branch $BRANCH to origin"

git -C "$TARGET_DIR" branch --set-upstream-to="origin/$BRANCH" "$BRANCH" >/dev/null 2>&1 || true

log "Repository ready at $TARGET_DIR on branch $BRANCH"

