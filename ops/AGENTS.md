# ops/ Agent Instructions

This directory is the operational control surface for jankurai-paper: pinned CI
script entrypoints and the mandatory pre-push hook.

## Owns

- `ops/ci/*.sh` — the lane scripts (`required`, `fast`, `audit`,
  `quality-gates`) plus the shared `lib.sh`. These are the single source of truth
  for the commands CI and local runs both execute.
- `ops/git-hooks/pre-push` — the mandatory pre-push gate; wire it with
  `git config core.hooksPath ops/git-hooks`.

## Forbidden

- Do not add GitHub Actions workflows. GitHub is a publishing mirror only; CI
  runs on the forge and our own hosts and must delegate to `ops/ci/<lane>.sh`
  so local and CI behaviour never drift (HLT-042).
- Do not call `latexmk` or `jankurai` directly from CI; always go through a
  lane script so the pinned flags stay consistent.
- Do not hand-edit generated output (`target/`, `paper/jankurai.pdf`).

## Proof lane

Run `bash ops/ci/quality-gates.sh` (or `just check`) before handing off changes.
It builds the paper PDF and runs the jankurai self-audit, the same lanes CI
runs. Confirm your environment matches CI first with `bash scripts/ci-doctor.sh`.
