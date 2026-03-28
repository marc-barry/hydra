# Hydra

Docker images for [Ory Hydra](https://github.com/ory/hydra), rebuilt from source with the latest Go toolchain and patched dependencies.

## Why?

Ory Hydra's official Docker images sometimes ship with CVEs due to the lag between Go patch releases and Hydra releases. This repo allows us to patch them in a timely manner by rebuilding from source with the latest Go toolchain and updated dependencies. Built images are scanned with Trivy and fail on CRITICAL or HIGH findings.

See [ory/hydra#4080](https://github.com/ory/hydra/issues/4080) for background.

## Usage

```bash
docker pull ghcr.io/marc-barry/hydra:v26.2.0
```

The image is a drop-in replacement for `oryd/hydra`. It uses the same Alpine base, non-root user, and entrypoint.

```bash
docker run --rm ghcr.io/marc-barry/hydra:v26.2.0 version
```

## Image Tags

| Tag | Description |
|-----|-------------|
| `<hydra-version>` | Hydra release version (e.g. `v26.2.0`) |
| `<hydra-version>-go<go-version>` | Hydra version + Go version used to build |
| `latest` | Most recent build |

## Building Locally

```bash
docker build \
  --build-arg HYDRA_VERSION=v26.2.0 \
  -t hydra:v26.2.0 .
```

## Notes

- Built with `CGO_ENABLED=0` — no SQLite support (use PostgreSQL)
- Multi-platform: `linux/amd64` and `linux/arm64`
- Weekly automated rebuilds pick up new Go patch releases
