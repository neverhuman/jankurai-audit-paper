# Release process

GitHub is authoritative for `neverhuman/jankurai-paper`; `.jeryu/` records
historical integration metadata. Release tags use
`jankurai-paper-v<MAJOR.MINOR.PATCH>-split.<N>` from [SPLIT.md](../SPLIT.md).

## Version and release notes

[`VERSION`](../VERSION), `agent/standard-version.toml`, and the proposed tag
must agree. Changes are not recorded by hand: cutting the release generates the
notes from the commits since the previous release, using their subjects and
`Todo:` trailers. Write those generated notes into
[CHANGELOG.md](../CHANGELOG.md) under `Unreleased`, then promote `Unreleased` to
a dated version section in the reviewed release commit.
The private Node package contains CI tooling and is not separately published.

## Qualification before tagging

1. Install selected tools and TeX packages from `ops/ci/github-setup.sh`, use
   Node 24, and run `npm ci`.
2. Run `bash scripts/ci-doctor.sh`, then `just check`. The full gate includes
   tooling tests, TeX build, baseline comparison, strict security, actual proof
   execution and verification, required proofbind, and zero-drop ratchet.
   Resolve every failure.
3. Review the complete forge PR diff and the actual successful forge CI results
   for its exact head. Merge through the forge and qualify resulting main.
4. Retain the PDF, its SHA-256, audit and proof reports, security evidence,
   source commit/tree, and actual tool identities. Verify version agreement and
   this inventory before creating a versioned release tag.

GitHub is a publishing mirror only. CI runs on the forge and our own hosts, and
releases are built and signed on our servers. A separate change introduces
key-based release signing. Downstream consumers select immutable qualified tags.

## Build integrity and provenance

`just build` (the shared `ops/ci/build-paper.sh` entrypoint)
builds from committed TeX and data. The required lane verifies a nonempty regular
`target/paper/jankurai.pdf` and records `target/jankurai/paper-build.sha256`.
The PDF and TeX byproducts are generated outputs, not tracked source. Retain and
publish this exact PDF together with its checksum and selected source revision;
the required gate builds and verifies them but does not publish a release.
Run `sha256sum --check target/jankurai/paper-build.sha256` from the repository
root before copying the artifacts into the release inventory. Bind the
distributed PDF to that exact hash.
Bit-for-bit rebuilding additionally requires fixed TeX packages, fonts, and
timestamps; a successful build alone does not establish it.

The security lane requires fresh CycloneDX 1.6 from Syft, validates it against
pinned offline schemas, and scans it with Grype. The Node dependency lock is also
audited. A `tlmgr` listing is useful toolchain metadata but is not the required
validated CycloneDX inventory. A source-directory SBOM does not establish full
coverage of the runner's TeX installation; record that installation separately
in the release inventory.

Audit, proof, scanner, and failed-run artifacts remain in `quality-evidence`.
The public badge describes its linked audited revision with explicit source and
auditor provenance. Imported reports alone do not establish supervised execution
or release signing authority.

## Release gates and rollback

Require successful security and proof gates, reviewed source and artifact
inventory, and a verified restoration of the source backup before publication.
Monitor resulting-main checks and artifact hashes. Branch protection and
least-privilege publishing permissions are the abuse controls for this product.

If a release regresses, point consumers at the previous qualified immutable tag
and retained PDF. Preserve existing tags, assets, and failure evidence. Any
revert or correction goes through a new PR and full qualification before a new
release; rebuilding an old source tag must not silently replace its original PDF.

## Generate the release notes

The release preparer runs this command before creating the release PR. Set
`PREVIOUS_RELEASE_TAG` to the last published release tag; `VERSION` must already
name the candidate version:

```sh
: "${PREVIOUS_RELEASE_TAG:?set the previous published release tag}"
git rev-parse --verify "refs/tags/$PREVIOUS_RELEASE_TAG^{commit}"
git merge-base --is-ancestor "$PREVIOUS_RELEASE_TAG" HEAD
version=$(cat VERSION)
mkdir -p target/release-notes
{
  printf '## %s\n\n' "$version"
  git log --reverse --no-merges --format='- %s%n%(trailers:key=Todo)' "$PREVIOUS_RELEASE_TAG..HEAD"
} > "target/release-notes/$version.md"
```

Review that generated file for compatibility changes and rollback commits, then
insert the version block into `CHANGELOG.md` in the release PR. Preserve all
historical entries and carry existing pending `Unreleased` notes into the
release they describe. The command above performs generation; publication does
not invoke an implicit generator. Record rollback details in the revert commit
so the same command includes them in the next release.
