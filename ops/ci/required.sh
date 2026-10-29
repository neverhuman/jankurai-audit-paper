#!/usr/bin/env bash
# Required lane: the lightweight gate that must pass on every push.
# Builds the paper PDF from its canonical TeX source.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

log "required lane: auditor identity tests"
bash ops/ci/auditor-test.sh

log "required lane: ci-local lane contract"
bash scripts/ci-local-lanes-test.sh

log "required lane: CI rejection and artifact freshness tests"
npm test

log "required lane: TeX shell escape is refused"
bash scripts/tex-shell-escape-test.sh

bash ops/ci/build-paper.sh
