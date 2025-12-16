# Multi-stage build for gotify-macos

# Build stage
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache make git

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
ARG VERSION=dev
ARG BUILD_TIME=""
ARG COMMIT=""
ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build \
    -ldflags "-X github.com/tobiashochguertel/gotify-macos/internal/config.Version=${VERSION} -X github.com/tobiashochguertel/gotify-macos/internal/config.BuildTime=${BUILD_TIME} -X github.com/tobiashochguertel/gotify-macos/internal/config.Commit=${COMMIT}" \
    -o gotify-macos ./cmd/gotify-macos

# Final stage - minimal runtime image
FROM alpine:latest

# Install ca-certificates for HTTPS connections
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN adduser -D -s /bin/sh gotify

# Set working directory
WORKDIR /home/gotify

# Copy binary from builder stage
COPY --from=builder /app/gotify-macos .

# Change ownership to non-root user
RUN chown gotify:gotify gotify-macos

# Switch to non-root user
USER gotify

# Expose port (if needed for future features)
EXPOSE 8080

# Set default command
ENTRYPOINT ["./gotify-macos"]
