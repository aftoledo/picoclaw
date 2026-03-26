# ==========================================
# Stage 1: Builder
# ==========================================
FROM golang:1.26-alpine AS builder

# Install build dependencies: git, make, AND the C compilers (gcc, musl-dev)
RUN apk add --no-cache git make gcc musl-dev

# Set the working directory
WORKDIR /src

# Pass a specific version as a build argument, defaulting to 'main'
ARG PICOCLAW_VERSION=main

# Clone the repository
RUN git clone --depth 1 --branch ${PICOCLAW_VERSION} https://github.com/sipeed/picoclaw.git .

# IMPORTANT: Enable CGO so SQLite and Matrix encryption can compile
ENV CGO_ENABLED=1

# Run 'make deps' to download modules AND generate the embedded workspace files
RUN make deps

# Build the project
RUN make build


# ==========================================
# Stage 2: Runtime
# ==========================================
FROM debian:bookworm-slim

# Install the runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /src/picoclaw /app/picoclaw

EXPOSE 8080

CMD ["./picoclaw"]
