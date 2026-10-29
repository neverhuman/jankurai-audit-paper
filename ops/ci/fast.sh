#!/usr/bin/env bash
# Deterministic fast lane: the narrowest proof loop for agent iteration.
# Builds the paper PDF incrementally (latexmk reuses its .fdb_latexmk recorder
# cache to rebuild only changed sections), then runs a changed-surface,
# target-only jankurai self-audit. Identical command set is exposed locally via
# `just fast` and `bash scripts/ci-local.sh fast`.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"
require_auditor

log "fast lane: latexmk paper build (incremental)"
bash ops/ci/build-paper.sh

mkdir -p target/jankurai
log "fast lane: changed-fast target-only self-audit"
"$JANKURAI_BIN" audit . --changed-fast --changed-from origin/main --no-score-history --json target/jankurai/fast-score.json --md target/jankurai/fast-score.md
