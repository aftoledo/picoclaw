# ==========================================
# Stage 1: The Builder Environment
# ==========================================
FROM golang:1.26-alpine AS builder

# 1. Install standard build tools + C compilers (gcc/musl)
RUN apk add --no-cache git make gcc musl-dev

WORKDIR /src

ARG PICOCLAW_VERSION=main
RUN git clone --depth 1 --branch ${PICOCLAW_VERSION} https://github.com/sipeed/picoclaw.git .

# 2. Force CGO on so Matrix/SQLite libraries can compile
ENV CGO_ENABLED=1

# 3. Use the repo's Makefile (it runs generate steps to create the workspace!)
RUN make deps
RUN make build

# ==========================================
# Stage 2: The Slim Runtime Environment
# ==========================================
FROM debian:bookworm-slim

# Install standard runtime certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 4. Copy the compiled binary from the builder
COPY --from=builder /src/picoclaw /app/picoclaw

EXPOSE 8080

CMD ["./picoclaw"]
