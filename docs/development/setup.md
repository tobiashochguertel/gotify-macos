# Development Setup

This guide will help you set up a development environment for gotify-macos.

## Prerequisites

- Go 1.23 or later
- Git
- Make
- Docker (optional, for cross-platform testing)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tobiashochguertel/gotify-macos.git
   cd gotify-macos
   ```

2. **Install dependencies:**
   ```bash
   make deps
   ```

3. **Build the project:**
   ```bash
   make build
   ```

4. **Run tests:**
   ```bash
   make test
   ```

## Development Workflow

### Project Structure

The project follows the standard Go project layout:

- `cmd/gotify-macos/` - Main application entry point
- `internal/config/` - Configuration management package
- `internal/notification/` - Notification handling package
- `test/` - All test files
- `docs/` - Documentation

### Building

```bash
# Build for current platform
make build

# Build for all platforms
make build-all

# Install using go install
make install
```

### Testing

```bash
# Run unit tests
make test

# Run cross-platform tests (requires Docker)
./scripts/test-cross-platform.sh
```

### Code Style

- Follow standard Go conventions
- Use `go fmt` for formatting
- Run `go vet` for static analysis
- Write tests for new functionality

### Version Information

Version information is embedded at build time using ldflags:

```bash
go build -ldflags "
  -X github.com/tobiashochguertel/gotify-macos/internal/config.Version=v1.0.0
  -X github.com/tobiashochguertel/gotify-macos/internal/config.BuildTime=$(date -u '+%Y-%m-%d_%H:%M:%S')
  -X github.com/tobiashochguertel/gotify-macos/internal/config.Commit=$(git rev-parse HEAD)
" ./cmd/gotify-macos
```

## Cross-Platform Testing

Use Docker for testing builds across different platforms:

```bash
# Test all platforms
./scripts/test-cross-platform.sh

# Test specific platform
docker-compose -f docker-compose.test.yml run test-linux
```

## IDE Setup

### VS Code

Recommended extensions:
- Go extension by Google
- Go Test Explorer
- Docker

### GoLand/IntelliJ

Configure Go SDK to version 1.23+

## Debugging

Set breakpoints in your IDE or use `dlv` for command-line debugging:

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
dlv debug ./cmd/gotify-macos
```

## Contributing

See [contributing.md](contributing.md) for contribution guidelines.