# Use Go 1.26 to satisfy the >= 1.25.8 requirement
FROM golang:1.26-alpine AS builder

# Install build tools and C-libraries for Matrix encryption
RUN apk add --no-cache git make build-base olm-dev

WORKDIR /src

# Clone the specific version/branch from your Railway variables
ARG PICOCLAW_VERSION=main
RUN git clone --depth 1 --branch ${PICOCLAW_VERSION} https://github.com/sipeed/picoclaw.git .

# Enable CGO (required for libolm and SQLite)
ENV CGO_ENABLED=1

# FIX: The 'pattern workspace: no matching files' error from your logs
# We must move the workspace folder to where the 'embed' directive expects it
RUN mkdir -p cmd/picoclaw/internal/onboard/workspace && \
    cp -r workspace/* cmd/picoclaw/internal/onboard/workspace/

# Build the binary using the official Makefile
RUN make build

# Runtime Stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libolm3 && rm -rf /var/lib/apt/lists/*

# Move to the app directory
WORKDIR /app

# Copy the binary
COPY --from=builder /src/build/picoclaw /app/picoclaw

# ADD THIS LINE HERE:
COPY config.json /app/config.json

# Hard-force the network settings
ENV PICOCLAW_SERVER_ADDR=0.0.0.0
ENV PICOCLAW_SERVER_PORT=18790
ENV PORT=18790

EXPOSE 8080
CMD ["./picoclaw", "gateway", "--allow-empty", "--addr", "0.0.0.0", "--port", "8080"]
