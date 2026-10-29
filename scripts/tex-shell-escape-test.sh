#!/usr/bin/env bash
# Negative test: with the repository .latexmkrc, TeX source that tries to run a
# command (\write18 and a piped \input) must not execute it, in every engine
# the rc file configures. A missing latexmk is a failure, not a skip.
# RC_FILE overrides the rc file under test (used to prove the test can fail).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
root="$PWD"
rc="${RC_FILE:-.latexmkrc}"
command -v latexmk >/dev/null 2>&1 || { echo "FAIL: latexmk not installed" >&2; exit 1; }
mkdir -p target
work="$(mktemp -d "$root/target/tex-shell-escape.XXXXXX")"
trap 'rm -rf "$work"' EXIT
cp "$rc" "$work/.latexmkrc"
cat > "$work/evil.tex" <<'TEX'
\documentclass{article}
\begin{document}
\immediate\write18{echo x > pwned-write18}
\input{|"echo x > pwned-pipe"}
hello
\end{document}
TEX
failures=0
for flag in -pdf -lualatex -xelatex; do
  rm -rf "$work/out"
  # The build may fail or succeed; only command execution matters.
  (cd "$work" && latexmk "$flag" -interaction=nonstopmode -halt-on-error -outdir=out evil.tex >/dev/null 2>&1) || true
  if [ -e "$work/pwned-write18" ] || [ -e "$work/pwned-pipe" ] || [ -e "$work/out/pwned-write18" ] || [ -e "$work/out/pwned-pipe" ]; then
    echo "FAIL: latexmk $flag executed a shell command from TeX source" >&2
    failures=$((failures + 1))
    rm -f "$work"/pwned-* "$work"/out/pwned-*
  else
    echo "ok: latexmk $flag did not execute shell commands"
  fi
done
[ "$failures" -eq 0 ]
