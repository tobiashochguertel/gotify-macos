# Getting Started with gotify-macos

This guide will help you get started with gotify-macos, a native macOS client for receiving Gotify notifications.

## Installation

### Option 1: Using go install (Recommended)

Install the latest version:
```bash
go install github.com/tobiashochguertel/gotify-macos@latest
```

Install a specific version:
```bash
go install github.com/tobiashochguertel/gotify-macos@v1.0.0
```

### Option 2: Download Pre-built Binary

1. Go to the [Releases page](https://github.com/tobiashochguertel/gotify-macos/releases)
2. Download the appropriate binary for your platform:
   - macOS Intel: `gotify-macos-darwin-amd64`
   - macOS Apple Silicon: `gotify-macos-darwin-arm64`
   - Linux: `gotify-macos-linux-amd64` or `gotify-macos-linux-arm64`
   - Windows: `gotify-macos-windows-amd64.exe` or `gotify-macos-windows-arm64.exe`
3. Make it executable (macOS/Linux): `chmod +x gotify-macos-*`
4. Move to your PATH (optional): `mv gotify-macos-* /usr/local/bin/gotify-macos`

### Option 3: Build from Source

```bash
git clone https://github.com/tobiashochguertel/gotify-macos.git
cd gotify-macos
make build
```

The binary will be available in the `bin/` directory.

## Setup

### 1. Get a Gotify Client Token

1. Open your Gotify web interface
2. Navigate to "Clients" section
3. Click "Create Client"
4. Give it a name (e.g., "macOS Notifications")
5. Copy the generated token

### 2. Configure gotify-macos

Run gotify-macos with your server details:

```bash
gotify-macos --host=your-gotify-server.com:8080 --token=your-client-token
```

## Usage Examples

### Connect to Local Server

```bash
gotify-macos --host=localhost:8080 --token=AbCdEf123456
```

### Connect to Remote Server

```bash
gotify-macos --host=gotify.example.com:443 --token=AbCdEf123456
```

### Check Version

```bash
gotify-macos --version
```

## Command Line Options

| Flag | Description | Default | Required |
|------|-------------|---------|----------|
| `--host` | Gotify server address | `0.0.0.0:8080` | No |
| `--token` | Client token from Gotify | | Yes |
| `--version` | Show version information | | No |

## Troubleshooting

### Common Issues

#### "Client token is required"
Make sure you provide the `--token` flag with a valid client token from your Gotify server.

#### Connection Refused
- Check that your Gotify server is running
- Verify the host and port are correct
- Ensure the server is accessible from your machine

#### No Notifications Appearing
- Check that notifications are enabled in your OS settings
- Verify the client token has the correct permissions
- Test by sending a message through the Gotify web interface

### Debug Mode

For troubleshooting, you can run with verbose logging:

```bash
gotify-macos --host=your-server.com:8080 --token=your-token 2>&1 | tee gotify.log
```

## Running as a Service

### macOS (launchd)

Create a launch agent plist file at `~/Library/LaunchAgents/com.gotify.macos.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.gotify.macos</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/gotify-macos</string>
        <string>--host=your-server.com:8080</string>
        <string>--token=your-token</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Load and start:
```bash
launchctl load ~/Library/LaunchAgents/com.gotify.macos.plist
launchctl start com.gotify.macos
```

### Linux (systemd)

Create a service file at `~/.config/systemd/user/gotify-macos.service`:

```ini
[Unit]
Description=Gotify macOS Client
After=network.target

[Service]
ExecStart=/usr/local/bin/gotify-macos --host=your-server.com:8080 --token=your-token
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

Enable and start:
```bash
systemctl --user daemon-reload
systemctl --user enable gotify-macos.service
systemctl --user start gotify-macos.service
```

## Next Steps

- [API Documentation](../api/reference.md)
- [Docker Deployment](../deployment/docker.md)
- [Development Setup](../development/setup.md)