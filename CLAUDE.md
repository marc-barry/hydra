# CLAUDE.md

## Purpose

This repo rebuilds [Ory Hydra](https://github.com/ory/hydra) Docker images from source to patch CVEs that the official images carry. It works around the lag between Go security releases and Hydra releases (see [ory/hydra#4080](https://github.com/ory/hydra/issues/4080)).

## How It Works

- **Dockerfile**: Multi-stage build. The builder stage clones the Hydra source at a given tag, patches known vulnerable Go dependencies, and builds with `CGO_ENABLED=0`. The runtime stage is Alpine with a non-root user (UID/GID 65532).
- **GitHub Actions** (`.github/workflows/build.yaml`): Builds multi-platform images (`linux/amd64`, `linux/arm64`), pushes to GHCR, and scans with Trivy. Triggered manually via `workflow_dispatch` or weekly on a cron schedule.
- **`.trivyignore`**: Documents accepted CVEs that have no upstream fix. Each entry should include a comment explaining why it's accepted.

## Key Details

- The Hydra go.mod has `replace` directives (`ory/x => ./oryx`, `hydra-client-go => ./internal/httpclient`), so the full source tree is needed — a simple `go install` won't work.
- `CGO_ENABLED=0` means no SQLite support. This is intentional — production uses PostgreSQL.
- The dependency patch step in the Dockerfile targets specific known-vulnerable packages rather than running `go get -u ./...`, which risks breaking changes.
- The Alpine base image uses a major version pin (e.g. `alpine:3`) so minor/patch updates are picked up automatically, combined with `apk upgrade` during build.

## Adding a New Hydra Version

1. Trigger the workflow with the new Hydra release tag
2. If the build fails, check if new `replace` directives or build flags were added upstream in `.docker/Dockerfile-alpine` or `.docker/Dockerfile-local-build`
3. If Trivy finds new CVEs, add targeted `go get` commands to the Dockerfile patch step or update `.trivyignore` if no fix is available

## Updating Patched Dependencies

When new CVEs are reported in Go dependencies, add `go get <module>@latest` to the patch step in the Dockerfile. Only patch what's needed — don't blanket upgrade.
