# Gotify macOS

A native macOS client for receiving [Gotify](https://gotify.net/) notifications as native macOS notifications.

[![CI](https://github.com/tobiashochguertel/gotify-macos/actions/workflows/ci.yml/badge.svg)](https://github.com/tobiashochguertel/gotify-macos/actions/workflows/ci.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/tobiashochguertel/gotify-macos)](https://goreportcard.com/report/github.com/tobiashochguertel/gotify-macos)

## Features

- Connects to Gotify server via WebSocket
- Displays Gotify messages as native macOS notifications
- Cross-platform support (Linux, macOS, Windows)
- Lightweight and fast

## Installation

### Using go install (Recommended)

Install the latest version:
```bash
go install github.com/tobiashochguertel/gotify-macos@latest
```

Install a specific version:
```bash
go install github.com/tobiashochguertel/gotify-macos@v1.0.0
```

### Download Binary

Download pre-built binaries from the [Releases page](https://github.com/tobiashochguertel/gotify-macos/releases).

Available platforms:
- Linux (amd64, arm64)
- macOS (amd64, arm64) 
- Windows (amd64, arm64)

### Build from Source

#### Prerequisites
- Go 1.21 or later
- Git

#### Quick Build
```bash
git clone https://github.com/tobiashochguertel/gotify-macos.git
cd gotify-macos
make build
```

The binary will be available in the `bin/` directory.

#### Build for All Platforms
```bash
make build-all
```

This creates binaries for all supported platforms in the `bin/` directory.

#### Install from Source
```bash
git clone https://github.com/tobiashochguertel/gotify-macos.git
cd gotify-macos
make install
```

## Usage

### Basic Usage
```bash
gotify-macos --host=your-gotify-server.com:8080 --token=your-client-token
```

### Command Line Options

- `--host`: Gotify server address (default: "0.0.0.0:8080")
- `--token`: Client token from your Gotify server (required)
- `--version`: Show version information

### Examples

Connect to a local Gotify server:
```bash
gotify-macos --host=localhost:8080 --token=AbCdEf123456
```

Connect to a remote server with HTTPS:
```bash
gotify-macos --host=gotify.example.com:443 --token=AbCdEf123456
```

Show version information:
```bash
gotify-macos --version
```

## Configuration

### Getting a Client Token

1. Open your Gotify web interface
2. Go to "Clients" section
3. Create a new client
4. Copy the generated token

## Development

### Available Make Targets

```bash
make help          # Show available targets
make build         # Build binary for current platform
make build-all     # Build for all platforms
make test          # Run tests
make clean         # Clean build directory
make deps          # Download dependencies
make run           # Build and run
make install       # Install using go install
```

### Dependencies

- [gorilla/websocket](https://github.com/gorilla/websocket) - WebSocket client
- [gen2brain/beeep](https://github.com/gen2brain/beeep) - Cross-platform notifications

### Testing

Run tests:
```bash
make test
```

Or using Go directly:
```bash
go test -v ./...
```

## CI/CD

This project uses GitHub Actions for:

- **CI Pipeline**: Automatically runs tests and builds on every push/PR
- **Release Pipeline**: Creates tagged releases with pre-built binaries

### Creating a Release

Releases are created manually using GitHub Actions:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Release" workflow
3. Click "Run workflow"
4. Enter the version (e.g., `v1.0.0`) and optional release notes
5. Click "Run workflow"

This will:
- Create a git tag
- Build binaries for all platforms
- Create a GitHub release
- Upload binaries as release assets

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Commit your changes (`git commit -am 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is open source. Please check the LICENSE file for details.

## Acknowledgments

- [Gotify](https://gotify.net/) - Simple server for sending and receiving messages
- Built with ❤️ for the macOS community
