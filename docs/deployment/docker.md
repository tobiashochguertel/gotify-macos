# Docker Deployment

This guide covers how to deploy gotify-macos using Docker.

## Docker Image

The gotify-macos project provides a multi-stage Docker build that creates a minimal Alpine Linux image with the gotify-macos binary.

### Building the Image

```bash
# Build with default settings
docker build -t gotify-macos .

# Build with custom version info
docker build -t gotify-macos:v1.0.0 \
  --build-arg VERSION=v1.0.0 \
  --build-arg BUILD_TIME="$(date -u '+%Y-%m-%d_%H:%M:%S')" \
  --build-arg COMMIT="$(git rev-parse HEAD)" \
  .
```

### Running the Container

```bash
# Basic run
docker run --rm gotify-macos:latest \
  --host=your-gotify-server.com:8080 \
  --token=your-client-token

# Run in background
docker run -d --name gotify-macos-client \
  --restart unless-stopped \
  gotify-macos:latest \
  --host=your-gotify-server.com:8080 \
  --token=your-client-token
```

### Environment Variables

You can also use a wrapper script to set configuration via environment variables:

```bash
# Create a wrapper script
cat > docker-entrypoint.sh << 'EOF'
#!/bin/sh
exec ./gotify-macos \
  --host="${GOTIFY_HOST:-0.0.0.0:8080}" \
  --token="${GOTIFY_TOKEN}"
EOF

# Build with wrapper
docker build -t gotify-macos-env .

# Run with environment variables
docker run -d --name gotify-macos-client \
  -e GOTIFY_HOST=your-server.com:8080 \
  -e GOTIFY_TOKEN=your-token \
  gotify-macos-env:latest
```

## Docker Compose

### Basic Setup

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  gotify-macos:
    build: .
    container_name: gotify-macos-client
    restart: unless-stopped
    command: [
      "--host=your-gotify-server.com:8080",
      "--token=your-client-token"
    ]
    # Optional: Add health check
    healthcheck:
      test: ["CMD", "pgrep", "-f", "gotify-macos"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### With Environment Variables

```yaml
version: '3.8'

services:
  gotify-macos:
    build: .
    container_name: gotify-macos-client
    restart: unless-stopped
    environment:
      - GOTIFY_HOST=${GOTIFY_HOST:-localhost:8080}
      - GOTIFY_TOKEN=${GOTIFY_TOKEN}
    command: [
      "--host=${GOTIFY_HOST}",
      "--token=${GOTIFY_TOKEN}"
    ]
```

Create a `.env` file:
```bash
GOTIFY_HOST=your-server.com:8080
GOTIFY_TOKEN=your-client-token
```

### Full Stack with Gotify Server

```yaml
version: '3.8'

services:
  gotify-server:
    image: gotify/server:latest
    container_name: gotify-server
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - gotify_data:/app/data
    environment:
      - GOTIFY_DEFAULTUSER_NAME=admin
      - GOTIFY_DEFAULTUSER_PASS=admin

  gotify-macos:
    build: .
    container_name: gotify-macos-client
    restart: unless-stopped
    depends_on:
      - gotify-server
    command: [
      "--host=gotify-server:80",
      "--token=${GOTIFY_TOKEN}"
    ]

volumes:
  gotify_data:
```

## Cross-Platform Images

### Multi-Architecture Build

Build images for multiple architectures:

```bash
# Enable buildx
docker buildx create --use

# Build multi-arch image
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  --tag gotify-macos:latest \
  --push \
  .
```

### Platform-Specific Builds

```bash
# Linux AMD64
docker build --platform linux/amd64 -t gotify-macos:linux-amd64 .

# Linux ARM64  
docker build --platform linux/arm64 -t gotify-macos:linux-arm64 .

# Linux ARM v7
docker build --platform linux/arm/v7 -t gotify-macos:linux-arm-v7 .
```

## Docker Registry

### Pushing to Registry

```bash
# Tag for registry
docker tag gotify-macos:latest your-registry.com/gotify-macos:latest

# Push to registry
docker push your-registry.com/gotify-macos:latest
```

### Using from Registry

```bash
# Pull and run
docker pull your-registry.com/gotify-macos:latest
docker run -d --name gotify-macos-client \
  your-registry.com/gotify-macos:latest \
  --host=server.com:8080 \
  --token=token
```

## Kubernetes Deployment

### Basic Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gotify-macos
  labels:
    app: gotify-macos
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gotify-macos
  template:
    metadata:
      labels:
        app: gotify-macos
    spec:
      containers:
      - name: gotify-macos
        image: gotify-macos:latest
        args:
        - "--host=gotify-server.default.svc.cluster.local:8080"
        - "--token=$(GOTIFY_TOKEN)"
        env:
        - name: GOTIFY_TOKEN
          valueFrom:
            secretKeyRef:
              name: gotify-secrets
              key: client-token
        resources:
          limits:
            memory: "128Mi"
            cpu: "100m"
          requests:
            memory: "64Mi"
            cpu: "50m"
```

### Secret Management

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gotify-secrets
type: Opaque
data:
  client-token: <base64-encoded-token>
```

## Monitoring and Logging

### Health Checks

```yaml
healthcheck:
  test: ["CMD", "pgrep", "-f", "gotify-macos"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 10s
```

### Logging Configuration

```yaml
services:
  gotify-macos:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Prometheus Metrics (Future)

When metrics support is added:

```yaml
# Expose metrics port
ports:
  - "9090:9090"  # metrics port
```

## Security Considerations

1. **Non-root User**: The Docker image runs as a non-root user
2. **Secrets Management**: Use Docker secrets or Kubernetes secrets for tokens
3. **Network Security**: Use TLS for Gotify server connections
4. **Image Scanning**: Regularly scan images for vulnerabilities

```bash
# Scan image for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image gotify-macos:latest
```