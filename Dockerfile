ARG GO_VERSION=1.26
ARG ALPINE_VERSION=3
ARG HYDRA_VERSION=v26.2.0

# Stage 1: Build
FROM golang:${GO_VERSION}-alpine AS builder
ARG HYDRA_VERSION

RUN apk add --no-cache git

WORKDIR /src
RUN git clone --depth 1 --branch ${HYDRA_VERSION} https://github.com/ory/hydra.git .

# Patch known CVE dependencies
RUN go get golang.org/x/crypto@latest && \
    go get go.opentelemetry.io/otel/sdk@latest && \
    go mod tidy

RUN CGO_ENABLED=0 go build -o /usr/bin/hydra .

# Stage 2: Runtime
FROM alpine:${ALPINE_VERSION}

RUN <<HEREDOC
    apk upgrade --no-cache
    apk add --no-cache ca-certificates

    addgroup --system --gid 65532 nonroot
    adduser --system --uid 65532 \
      --gecos "nonroot User" \
      --home /home/nonroot \
      --ingroup nonroot \
      --shell /sbin/nologin \
      nonroot
HEREDOC

COPY --from=builder /usr/bin/hydra /usr/bin/hydra

USER nonroot

ENTRYPOINT ["hydra"]
CMD ["serve", "all"]
