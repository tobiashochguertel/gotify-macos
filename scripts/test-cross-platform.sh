#!/bin/bash

# Cross-platform testing script for gotify-macos
# This script tests builds for different platforms using Docker

set -e

echo "🚀 Starting cross-platform build tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_warning "docker-compose not found, trying docker compose..."
    if ! docker compose version &> /dev/null; then
        print_error "Neither docker-compose nor docker compose is available"
        exit 1
    fi
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

print_status "Docker environment detected"

# Clean up previous runs
echo "🧹 Cleaning up previous test artifacts..."
rm -rf bin/
mkdir -p bin/

# Function to run tests for a specific service
run_test() {
    local service=$1
    local description=$2
    
    echo "🔄 Testing: $description"
    if $DOCKER_COMPOSE -f docker-compose.test.yml run --rm $service; then
        print_status "$description completed successfully"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Run individual tests
echo "📋 Running individual platform tests..."

run_test "test-linux" "Linux AMD64 build" || exit 1
run_test "test-linux-arm64" "Linux ARM64 cross-compilation" || exit 1
run_test "test-windows" "Windows cross-compilation" || exit 1

# Run comprehensive test
echo "🔄 Running comprehensive test suite..."
run_test "test-all" "Comprehensive test and build" || exit 1

# Test Docker build
echo "🐳 Testing Docker build..."
if docker build -t gotify-macos-test \
    --build-arg VERSION="test-$(date +%s)" \
    --build-arg BUILD_TIME="$(date -u '+%Y-%m-%d_%H:%M:%S')" \
    --build-arg COMMIT="$(git rev-parse HEAD 2>/dev/null || echo 'unknown')" \
    .; then
    print_status "Docker build completed successfully"
    
    # Test the Docker image
    echo "🧪 Testing Docker image..."
    if docker run --rm gotify-macos-test --version; then
        print_status "Docker image test passed"
    else
        print_error "Docker image test failed"
        exit 1
    fi
    
    # Clean up Docker image
    docker rmi gotify-macos-test >/dev/null 2>&1 || true
else
    print_error "Docker build failed"
    exit 1
fi

# Show build artifacts
echo "📦 Build artifacts created:"
ls -la bin/ 2>/dev/null || echo "No build artifacts found"

echo ""
print_status "🎉 All cross-platform tests completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review the build artifacts in the bin/ directory"
echo "2. Run 'make test' for local unit tests"  
echo "3. Push changes to trigger GitHub Actions CI/CD"
echo ""
