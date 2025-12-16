# Gotify macOS Documentation

This directory contains comprehensive documentation for the gotify-macos project.

## Documentation Structure

- **[API](api/)** - API documentation and examples
- **[Development](development/)** - Development guides and setup instructions  
- **[Deployment](deployment/)** - Deployment guides and Docker information
- **[User Guide](user-guide/)** - End-user documentation and tutorials

## Quick Links

- [Getting Started](user-guide/getting-started.md)
- [Development Setup](development/setup.md)  
- [API Reference](api/reference.md)
- [Docker Deployment](deployment/docker.md)
- [Contributing](development/contributing.md)

## Project Structure

The gotify-macos project follows standard Go project layout:

```
├── cmd/gotify-macos/     # Main application entry point
├── internal/             # Private application code
│   ├── config/          # Configuration management
│   └── notification/    # Notification handling
├── pkg/gotify/          # Public library code (future)
├── test/                # Test files
├── docs/                # Documentation
├── scripts/             # Build and development scripts
└── bin/                 # Built binaries
```

For more detailed information, please refer to the specific documentation sections.