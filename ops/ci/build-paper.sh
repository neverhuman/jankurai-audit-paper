#!/usr/bin/env bash
# Shared paper build for required, fast, just build and mapped proof callers.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

log "paper build: canonical target/paper artifact"
mkdir -p target/paper target/jankurai
latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=target/paper paper/jankurai.tex
if [[ ! -f target/paper/jankurai.pdf || -L target/paper/jankurai.pdf || ! -s target/paper/jankurai.pdf ]]; then
  printf '[ci] paper build did not produce a nonempty regular PDF\n' >&2
  exit 1
fi
sha256sum target/paper/jankurai.pdf > target/jankurai/paper-build.sha256
