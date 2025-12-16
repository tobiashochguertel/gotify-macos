# Local GitHub Actions Workflow Testing

**Stop the painful try-and-error cycle!** This guide shows how to test GitHub Actions workflows locally before pushing to GitHub.

## The Problem

GitHub Actions development traditionally involves:
1. Write workflow
2. Push to GitHub
3. Wait for workflow to run
4. It fails with some error
5. Fix error
6. Repeat 10+ times 🤬

This is slow, wastes CI minutes, and frustrating!

## The Solution: Local Testing with `act`

We use [`nektos/act`](https://github.com/nektos/act) to run GitHub Actions workflows locally using Docker containers that simulate GitHub's runners.

## Quick Start

### 1. Test All Workflows
```bash
make validate-workflows    # Just validate syntax
make test-workflows       # Interactive testing menu
```

### 2. Test Specific Workflows
```bash
# Test CI workflow
./scripts/test-workflows.sh ci

# Test specific job
./scripts/test-workflows.sh job test

# List all available workflows/jobs
./scripts/test-workflows.sh list
```

### 3. Interactive Menu
```bash
./scripts/test-workflows.sh
# Shows interactive menu with all options
```

## How It Works

### Configuration Files

#### `.actrc` - Runner Configuration
```bash
# Use medium-sized runners (balance of size vs tools)
-P ubuntu-latest=catthehacker/ubuntu:act-latest
--artifact-server-path /tmp/artifacts
```

#### `.env.act` - Environment Variables
```bash
# Test environment variables and secrets
GOTIFY_HOST=localhost:8080
GOTIFY_TOKEN=test-token
```

### Available Commands

| Command | Description |
|---------|-------------|
| `make test-workflows` | Interactive menu for workflow testing |
| `make validate-workflows` | Validate workflow syntax only |
| `act -l` | List all workflows and jobs |
| `act push` | Test push event workflows |
| `act workflow_dispatch` | Test manual trigger workflows |
| `act -j job_name` | Test specific job |

## Detailed Usage

### 1. Validate Workflow Syntax
```bash
# Quick syntax check
make validate-workflows

# Detailed validation with act
act --dry-run
```

### 2. Test CI Workflow
```bash
# Test the entire CI pipeline
./scripts/test-workflows.sh ci

# Test just the build job
act push -j build

# Test just the test job
act push -j test
```

### 3. Test Release Workflow
```bash
# Test with custom inputs
./scripts/test-workflows.sh release

# Or manually with inputs
act workflow_dispatch \
  --input version=v1.0.0-test \
  --input release_notes="Test release"
```

### 4. Debug Failed Workflows
```bash
# Run with verbose output
act push --verbose

# Run with shell access on failure
act push --shell

# Use specific runner image
act push -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

## Runner Images

### Default (Medium) - Recommended
- **Size**: ~500MB-1GB
- **Tools**: Basic development tools, common runtimes
- **Use**: Most workflows, good balance

```bash
# Already configured in .actrc
act push  # Uses medium runner
```

### Large (Full GitHub Environment)
- **Size**: 18GB+ per platform
- **Tools**: Exact same as GitHub hosted runners
- **Use**: Complex workflows requiring many tools

```bash
# Use full runner for exact GitHub environment
act push -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

### Micro (Minimal)
- **Size**: ~50MB
- **Tools**: Very basic
- **Use**: Simple workflows, quick tests

```bash
act push -P ubuntu-latest=node:16-bullseye-slim
```

## Common Workflows

### 1. Developing New Workflow

```bash
# 1. Create workflow file
vim .github/workflows/new-workflow.yml

# 2. Validate syntax
make validate-workflows

# 3. Test locally
act push --workflows .github/workflows/new-workflow.yml

# 4. Debug if needed
act push --workflows .github/workflows/new-workflow.yml --verbose

# 5. Push when working
git add .github/workflows/new-workflow.yml
git commit -m "Add new workflow"
git push
```

### 2. Debugging Existing Workflow

```bash
# 1. Run locally with verbose output
act push --verbose

# 2. Check specific job
act push -j failing_job_name

# 3. Use shell to debug
act push -j failing_job_name --shell

# 4. Fix and test again
act push
```

### 3. Testing Cross-Platform Builds

```bash
# Test matrix builds locally
act push -j build

# Note: act runs all matrix combinations in parallel
# Check artifacts in /tmp/artifacts
```

## Advanced Features

### Custom Environment
```bash
# Create local environment file
cp .env.act .env.act.local

# Edit with your settings
vim .env.act.local

# Use custom env file
act push --env-file .env.act.local
```

### Secrets Management
```bash
# Set secrets for testing
act push -s GITHUB_TOKEN=your_token_here

# Or use secrets file
echo "GITHUB_TOKEN=your_token" > .secrets
act push --secret-file .secrets
```

### Artifact Testing
```bash
# Artifacts are saved to /tmp/artifacts by default
act push

# Check generated artifacts
ls /tmp/artifacts/
```

## Troubleshooting

### Common Issues

#### 1. "Docker not found"
```bash
# Make sure Docker is running
docker version

# On macOS with Colima
colima start
```

#### 2. "Container architecture warnings" (Apple Silicon)
```bash
# Run with specific architecture
act push --container-architecture linux/amd64
```

#### 3. "Action not found"
```bash
# Pull latest runner images
docker pull catthehacker/ubuntu:act-latest

# Or use full image
act push -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

#### 4. "Missing tools in runner"
Switch to full runner image or install tools in workflow:

```yaml
steps:
  - uses: actions/checkout@v6
  - name: Install missing tools
    run: |
      apt-get update
      apt-get install -y your-tool
```

### Performance Tips

1. **Use .actrc**: Configure once, use everywhere
2. **Medium runners**: Good balance of size vs features
3. **Parallel jobs**: act runs matrix jobs in parallel
4. **Cache images**: Docker will cache pulled images
5. **Clean up**: `docker system prune` to free space

## Integration with Development

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit
echo "Validating GitHub Actions workflows..."
if ! make validate-workflows; then
    echo "❌ Workflow validation failed!"
    exit 1
fi
```

### VS Code Integration

Install the "GitHub Local Actions" extension for VS Code integration.

### Git Aliases
```bash
# Add to ~/.gitconfig
[alias]
    test-workflows = "!cd $(git rev-parse --show-toplevel) && make test-workflows"
    validate-workflows = "!cd $(git rev-parse --show-toplevel) && make validate-workflows"
```

## Best Practices

1. **Test Before Push**: Always validate workflows locally
2. **Use Medium Runners**: Good balance for most use cases
3. **Version Pin Actions**: Use specific versions (`@v6` not `@main`)
4. **Test Matrix Jobs**: Ensure all combinations work
5. **Check Artifacts**: Verify generated files
6. **Use Secrets Safely**: Never commit real secrets
7. **Clean Regularly**: Remove old Docker images and artifacts

## Comparison: Before vs After

### Before (Traditional Development)
```
Write workflow → Push → Wait → Fail → Fix → Push → Wait → Fail → ...
⏱️  Time: 5-10 minutes per iteration
💸 Cost: Uses GitHub Actions minutes
😤 Frustration: High
```

### After (Local Testing)
```
Write workflow → Test locally → Fix locally → Test locally → Push → ✅ Success
⏱️  Time: 30 seconds per iteration
💸 Cost: Free local testing
😊 Frustration: Minimal
```

## Resources

- [nektos/act Documentation](https://github.com/nektos/act)
- [act User Guide](https://nektosact.com/)
- [Runner Images](https://github.com/catthehacker/docker_images)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Bottom Line**: Never again spend hours debugging GitHub Actions in the cloud. Test everything locally first! 🎉