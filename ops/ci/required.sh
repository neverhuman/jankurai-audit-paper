#!/usr/bin/env bash
# Required lane: the lightweight gate that must pass on every push.
# Builds the paper PDF from its canonical TeX source.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

log "required lane: ci-local lane contract"
bash scripts/ci-local-lanes-test.sh

log "required lane: CI rejection and artifact freshness tests"
npm test

log "required lane: latexmk paper build"
# The published PDF is tracked source. Hosted proof must not rewrite it or
# its tracked TeX logs, otherwise the runner correctly rejects changed inputs.
mkdir -p target/paper
latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=target/paper paper/jankurai.tex
if [[ ! -f target/paper/jankurai.pdf || -L target/paper/jankurai.pdf || ! -s target/paper/jankurai.pdf ]]; then
  printf '[ci] paper build did not produce a nonempty regular PDF\n' >&2
  exit 1
fi
mkdir -p target/jankurai
sha256sum target/paper/jankurai.pdf > target/jankurai/paper-build.sha256
