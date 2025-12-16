# Local GitHub Actions Testing with Colima on Apple Silicon

This guide documents how to fix and configure `nektos/act` to work properly with Colima Docker backend on macOS Apple Silicon (M1/M2/M3).

## The Problem

When running `act` with Colima on Apple Silicon, several issues occur:

1. **Docker Socket Mount Issues**: Act can't mount the Colima socket properly inside containers
2. **Architecture Mismatches**: amd64 containers on arm64 hardware cause segmentation faults 
3. **Container Networking**: Colima handles networking differently than Docker Desktop
4. **Volume Mount Permissions**: Colima's volume mounting can conflict with act's expectations

## Our Specific Issues and Solutions

### Issue 1: Docker Socket Not Found

**Error:**
```
failed to start container: Error response from daemon: error while creating mount source path '/Users/tobiashochguertel/.colima/docker/docker.sock': mkdir /Users/tobiashochguertel/.colima/docker/docker.sock: operation not supported
```

**Root Cause**: Act expects the Docker socket at `/var/run/docker.sock`, but Colima uses a different path.

**Solution**: Create a symlink to map Colima's socket to the expected location:

```bash
sudo ln -sf /Users/tobiashochguertel/.colima/docker/docker.sock /var/run/docker.sock
```

### Issue 2: Architecture Compatibility

**Error:**
```
math: /opt/hostedtoolcache/go/1.23.12/x64/pkg/tool/linux_amd64/asm: signal: segmentation fault (core dumped)
```

**Root Cause**: Running amd64 containers on arm64 hardware through emulation causes instability.

**Solutions:**
1. **Use ARM64 containers** when available
2. **Ensure Colima has Rosetta enabled** for x86 emulation
3. **Use specific runner images** that work well with Apple Silicon

### Issue 3: Container Configuration

**Configuration Changes Made:**

#### Updated `.actrc`:
```bash
# act configuration file for Colima on Apple Silicon
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-22.04=catthehacker/ubuntu:act-22.04
-P ubuntu-20.04=catthehacker/ubuntu:act-20.04

# Container architecture for Apple Silicon compatibility
--container-architecture linux/amd64

# Docker daemon socket for Colima compatibility  
--container-daemon-socket /Users/tobiashochguertel/.colima/docker/docker.sock

# Network and file system compatibility
--use-gitignore=false
--artifact-server-path /tmp/artifacts
```

## Complete Fix Implementation

### Step 1: Verify Colima Setup

Check your Colima configuration:
```bash
colima status --profile docker
```

Expected output:
```
INFO[0001] colima [profile=docker] is running using macOS Virtualization.Framework
INFO[0001] arch: aarch64
INFO[0001] runtime: docker
INFO[0001] mountType: virtiofs
INFO[0001] docker socket: unix:///Users/tobiashochguertel/.colima/docker/docker.sock
```

### Step 2: Create Docker Socket Symlink

```bash
sudo ln -sf /Users/tobiashochguertel/.colima/docker/docker.sock /var/run/docker.sock
```

Verify:
```bash
ls -la /var/run/docker.sock
# Should show: lrwxr-xr-x@ 1 root daemon 50 Dec 16 21:57 /var/run/docker.sock -> /Users/tobiashochguertel/.colima/docker/docker.sock
```

### Step 3: Set Environment Variables

Add to your shell profile (`.zshrc`, `.bash_profile`):
```bash
export DOCKER_HOST="unix:///Users/tobiashochguertel/.colima/docker/docker.sock"
```

### Step 4: Update Act Configuration

Create/update `.actrc` with Colima-specific settings:
```bash
# Docker daemon socket for Colima compatibility
--container-daemon-socket /Users/tobiashochguertel/.colima/docker/docker.sock

# Container architecture (use amd64 with Rosetta, or arm64 for native)
--container-architecture linux/amd64

# Use reliable runner images
-P ubuntu-latest=catthehacker/ubuntu:act-latest

# Networking and artifact settings
--use-gitignore=false
--artifact-server-path /tmp/artifacts
```

### Step 5: Test Configuration

Test with dry run first:
```bash
act -j test --dryrun
```

If successful, test real execution:
```bash
act -j test
```

## Alternative Approaches

### Option 1: Use ARM64 Native Containers

For better stability, use ARM64 containers when possible:

```bash
act -j test \
  --container-architecture linux/arm64 \
  -P ubuntu-latest=ubuntu:22.04
```

**Note**: This requires installing Node.js and other dependencies in the container.

### Option 2: Use Full GitHub Runner Images

For maximum compatibility, use the full runner images:

```bash
act -j test -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

**Trade-off**: Much larger download (18GB+) but exact GitHub environment.

### Option 3: Docker Context Approach

Set up Docker context for Colima:
```bash
docker context create colima-act --docker "host=unix:///Users/tobiashochguertel/.colima/docker/docker.sock"
docker context use colima-act
```

## Troubleshooting Guide

### Issue: "Cannot connect to Docker daemon"

**Check**: 
```bash
docker ps
```

**Fix**: Ensure Colima is running and DOCKER_HOST is set correctly.

### Issue: "Platform mismatch" warnings

**Fix**: Add `--container-architecture linux/amd64` to act command.

### Issue: Segmentation faults in containers

**Cause**: Architecture mismatch or insufficient Rosetta support.

**Fix**: 
1. Restart Colima with Rosetta:
   ```bash
   colima stop
   colima start --cpu 4 --memory 4 --vm-type vz --vz-rosetta
   ```
2. Use ARM64 containers when possible
3. Use smaller, more stable images

### Issue: Volume mount errors

**Fix**: Ensure the project directory is in a Colima-accessible path (usually under `/Users`).

## Performance Optimization

### Colima Startup Optimizations

```bash
colima start \
  --cpu 4 \
  --memory 6 \
  --disk 60 \
  --vm-type vz \
  --vz-rosetta \
  --network-address
```

### Act Optimizations

```bash
# Use local cache to speed up subsequent runs
act -j test --use-gitignore=false --reuse

# Run specific jobs only
act -j test  # Only test job
act -j build  # Only build job
```

## Comparison: Docker Desktop vs Colima

| Feature | Docker Desktop | Colima |
|---------|---------------|--------|
| **Setup Complexity** | Simple | Moderate |
| **Resource Usage** | High | Lower |
| **Act Compatibility** | Excellent | Good (with fixes) |
| **Performance** | Good | Better |
| **License** | Paid (commercial) | Free |

## Final Working Configuration

After applying all fixes, this configuration works reliably:

**`.actrc`:**
```bash
--container-daemon-socket /Users/tobiashochguertel/.colima/docker/docker.sock
--container-architecture linux/amd64
-P ubuntu-latest=catthehacker/ubuntu:act-latest
--use-gitignore=false
--artifact-server-path /tmp/artifacts
```

**Shell environment:**
```bash
export DOCKER_HOST="unix:///Users/tobiashochguertel/.colima/docker/docker.sock"
```

**System symlink:**
```bash
/var/run/docker.sock -> /Users/tobiashochguertel/.colima/docker/docker.sock
```

## Success Metrics

After implementing these fixes:

✅ **Act dry runs** work without errors  
✅ **Docker containers start** properly  
✅ **GitHub Actions execute** (though may have architecture-specific issues)  
✅ **Socket mounting** works correctly  
✅ **Workflow validation** passes  

## Limitations and Workarounds

### Known Limitations:

1. **Architecture-specific builds** may still fail (Go assembly errors)
2. **Some GitHub Actions** expect specific tools not in minimal images
3. **Docker-in-Docker** workflows have additional complexity

### Workarounds:

1. **Test workflow logic** locally, verify cross-platform builds on GitHub
2. **Use workflow validation** (`make validate-workflows`) for syntax checking
3. **Run simplified tests** locally, full matrix testing on GitHub
4. **Mock external dependencies** for local testing

## Conclusion

While act + Colima requires more setup than Docker Desktop, it provides a free, performant alternative for local GitHub Actions testing. The key is proper socket configuration and architecture awareness.

**For this project**: We successfully configured local testing, but rely on GitHub for full cross-platform validation due to architecture-specific Go compilation issues.

## References

- [nektos/act Colima Issues](https://github.com/nektos/act/issues/5967)
- [Colima Configuration Guide](https://github.com/abiosoft/colima/blob/main/docs/FAQ.md)
- [Act Documentation](https://nektosact.com/)
- [Apple Silicon Docker Guide](https://marczin.dev/blog/macos-docker-setup/)