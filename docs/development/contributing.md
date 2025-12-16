# Contributing to gotify-macos

We welcome contributions to gotify-macos! This document provides guidelines for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Set up the development environment (see [setup.md](setup.md))
4. Create a feature branch
5. Make your changes
6. Test your changes
7. Submit a pull request

## Development Process

### Branching Strategy

- `main` - Stable release branch
- `develop` - Development branch for upcoming features
- Feature branches - `feature/description` or `fix/description`

### Code Standards

#### Go Style Guide

Follow the standard Go style guide:
- Use `gofmt` for formatting
- Follow naming conventions
- Write clear, self-documenting code
- Add comments for public APIs

#### Testing

- Write unit tests for new functionality
- Maintain or improve code coverage
- Test cross-platform compatibility
- Use table-driven tests where appropriate

Example test structure:
```go
func TestFunction(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
        wantErr  bool
    }{
        {
            name:     "valid input",
            input:    "test",
            expected: "expected",
            wantErr:  false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := Function(tt.input)
            if tt.wantErr && err == nil {
                t.Error("expected error but got nil")
            }
            if !tt.wantErr && err != nil {
                t.Errorf("unexpected error: %v", err)
            }
            if result != tt.expected {
                t.Errorf("expected %q, got %q", tt.expected, result)
            }
        })
    }
}
```

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes
- `refactor` - Code refactoring
- `test` - Test additions or changes
- `chore` - Maintenance tasks

Examples:
```
feat(notification): add support for custom notification sounds
fix(config): handle empty token validation properly
docs(api): update API documentation with new endpoints
```

### Pull Request Process

1. **Before submitting:**
   - Run tests: `make test`
   - Run cross-platform tests: `./scripts/test-cross-platform.sh`
   - Update documentation if needed
   - Add tests for new functionality

2. **Pull Request Title:**
   Use conventional commit format

3. **Pull Request Description:**
   - Describe what changes were made and why
   - Reference any related issues
   - Include testing information
   - Add screenshots/logs if relevant

4. **Review Process:**
   - At least one review required
   - All CI checks must pass
   - Address feedback promptly

### Testing Guidelines

#### Unit Tests
- Place tests in the `test/` directory
- Use package name `test`
- Import the packages being tested
- Test both happy path and error cases

#### Integration Tests
- Use Docker for cross-platform testing
- Test against real Gotify server when possible
- Mock external dependencies appropriately

#### Cross-Platform Testing
Run the cross-platform test suite before submitting:

```bash
./scripts/test-cross-platform.sh
```

## Issue Guidelines

### Bug Reports

Include:
- Operating system and version
- Go version
- Steps to reproduce
- Expected vs actual behavior
- Error messages/logs
- Minimal code example

### Feature Requests

Include:
- Clear description of the feature
- Use case and benefits
- Possible implementation approach
- Any relevant examples

## Release Process

1. Update version in appropriate files
2. Update CHANGELOG.md
3. Create release PR to main branch
4. Tag release after merge
5. GitHub Actions will build and publish binaries

## Code Review Guidelines

### For Reviewers

- Be constructive and specific
- Suggest improvements
- Approve when ready
- Test locally when needed

### For Authors

- Respond to feedback promptly
- Make requested changes
- Ask for clarification if unclear
- Update PR description if scope changes

## Getting Help

- Check existing issues and documentation
- Ask questions in pull requests
- Reach out to maintainers

Thank you for contributing to gotify-macos!