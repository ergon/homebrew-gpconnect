#!/bin/bash
# Moves an existing gpconnect tap from stash to GitHub, in place.
# The installed app, its settings and the stored password are untouched.
# Idempotent: safe to re-run, and safe on a machine already migrated.
set -euo pipefail

TAP_NAME="ergon/gpconnect"
REPO="ergon/homebrew-gpconnect"
APP="gpconnect"
TAP_DIR="$(brew --repository)/Library/Taps/ergon/homebrew-gpconnect"

if [ ! -d "${TAP_DIR}/.git" ]; then
    echo "==> The tap is not present; adding it fresh from GitHub."
    brew tap "$TAP_NAME"
else
    echo "==> Retargeting the tap at github.com/${REPO}..."
    if [ -d "${TAP_DIR}/.git/rebase-merge" ] || [ -d "${TAP_DIR}/.git/rebase-apply" ]; then
        echo "    A previous update left a rebase in progress; aborting it."
        git -C "$TAP_DIR" rebase --abort || true
    fi
    git -C "$TAP_DIR" remote set-url origin "https://github.com/${REPO}"
    git -C "$TAP_DIR" fetch --quiet origin
    # The old and new repositories share no history, and a tap clone is a disposable
    # mirror — reset it onto the new remote rather than letting brew try to rebase
    # months of old commits onto the GitHub head.
    git -C "$TAP_DIR" checkout --quiet main 2>/dev/null \
        || git -C "$TAP_DIR" checkout --quiet -b main
    git -C "$TAP_DIR" reset --hard --quiet origin/main
    git -C "$TAP_DIR" clean -qfd
    # Stashed hand-edits replay — and conflict — on every future pull; drop them.
    git -C "$TAP_DIR" stash clear 2>/dev/null || true
fi

# The remote changed, so the trust brew recorded for the tap no longer applies.
brew trust --cask "${TAP_NAME}/${APP}"

echo
echo "✓ Migrated. Update as usual:"
echo "    brew update && brew upgrade --cask ${APP}"
