#!/bin/bash

# Local GitHub Actions workflow testing script using act
# This eliminates the painful try-and-error cycle of GitHub Actions development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if act is installed
if ! command -v act &> /dev/null; then
    print_error "act is not installed. Install with: brew install act"
    exit 1
fi

print_header "Local GitHub Actions Workflow Testing"

# Function to run a workflow locally
test_workflow() {
    local event=$1
    local workflow_file=$2
    local description=$3
    local extra_args=${4:-}
    
    print_header "Testing: $description"
    echo "Event: $event"
    echo "Workflow: $workflow_file"
    
    if act $event \
        --workflows "$workflow_file" \
        --env-file .env.act \
        --artifact-server-path /tmp/artifacts \
        --verbose \
        $extra_args; then
        print_success "$description test passed"
        return 0
    else
        print_error "$description test failed"
        return 1
    fi
}

# Function to list available workflows
list_workflows() {
    print_header "Available Workflows"
    act -l
    echo ""
}

# Function to test CI workflow
test_ci() {
    print_header "Testing CI Workflow"
    
    # Check if we're on Apple Silicon with Colima
    if [[ $(uname -m) == "arm64" ]] && [[ -n "$DOCKER_HOST" ]] && [[ "$DOCKER_HOST" == *"colima"* ]]; then
        print_warning "Detected Apple Silicon with Colima - using compatible settings"
        
        # Test just syntax validation first
        print_header "Testing workflow syntax (Apple Silicon + Colima)"
        if act -j test --dryrun --container-architecture linux/amd64 2>/dev/null; then
            print_success "Workflow syntax validation passed"
        else
            print_error "Workflow has syntax errors"
            return 1
        fi
        
        print_warning "Skipping full execution due to architecture compatibility issues"
        print_warning "Use GitHub Actions for full cross-platform testing"
        return 0
    fi
    
    # Test push event (most common trigger)
    if test_workflow "push" ".github/workflows/ci.yml" "CI Push Event"; then
        print_success "CI workflow test passed"
    else
        print_error "CI workflow test failed"
        return 1
    fi
}

# Function to test release workflow
test_release() {
    print_header "Testing Release Workflow"
    
    # Create temporary input file for workflow_dispatch
    cat > /tmp/release_inputs.json << EOF
{
    "version": "v1.0.0-test",
    "release_notes": "Test release for local validation"
}
EOF
    
    if test_workflow "workflow_dispatch" ".github/workflows/release.yml" "Release Workflow" "--input-file /tmp/release_inputs.json"; then
        print_success "Release workflow test passed"
        rm -f /tmp/release_inputs.json
    else
        print_error "Release workflow test failed"
        rm -f /tmp/release_inputs.json
        return 1
    fi
}

# Function to test specific job
test_job() {
    local job_name=$1
    print_header "Testing specific job: $job_name"
    
    if act push -j "$job_name" --env-file .env.act --verbose; then
        print_success "Job $job_name test passed"
    else
        print_error "Job $job_name test failed"
        return 1
    fi
}

# Main menu
show_menu() {
    echo ""
    print_header "Local Workflow Testing Menu"
    
    # Show environment info
    if [[ $(uname -m) == "arm64" ]] && [[ -n "$DOCKER_HOST" ]] && [[ "$DOCKER_HOST" == *"colima"* ]]; then
        print_warning "Environment: Apple Silicon + Colima (limited compatibility mode)"
    else
        echo "Environment: Standard Docker setup"
    fi
    
    echo ""
    echo "1. List all workflows and jobs"
    echo "2. Test CI workflow (push event)"
    echo "3. Test Release workflow (workflow_dispatch)"
    echo "4. Test specific job"
    echo "5. Test all workflows"
    echo "6. Pull latest runner images"
    echo "7. Clean up artifacts and cache"
    echo "8. Show workflow syntax validation"
    echo "9. Check Colima/Docker setup"
    echo "10. Exit"
    echo ""
}

# Function to validate workflow syntax
validate_syntax() {
    print_header "Validating Workflow Syntax"
    
    # Check environment and adjust accordingly
    local extra_args=""
    if [[ $(uname -m) == "arm64" ]] && [[ -n "$DOCKER_HOST" ]] && [[ "$DOCKER_HOST" == *"colima"* ]]; then
        print_warning "Apple Silicon + Colima detected - using compatible validation"
        extra_args="--container-architecture linux/amd64"
    fi
    
    local workflows_dir=".github/workflows"
    local valid=true
    
    for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml; do
        if [[ -f "$workflow" ]]; then
            echo "Validating: $workflow"
            if act --dryrun -W "$workflow" $extra_args &>/dev/null; then
                print_success "✓ $workflow syntax is valid"
            else
                print_error "✗ $workflow has syntax errors"
                # Show the actual error
                echo "Error details:"
                act --dryrun -W "$workflow" $extra_args 2>&1 | head -5
                valid=false
            fi
        fi
    done
    
    if $valid; then
        print_success "All workflows have valid syntax"
    else
        print_error "Some workflows have syntax errors"
        return 1
    fi
}

# Function to pull latest images
pull_images() {
    print_header "Pulling Latest Runner Images"
    
    # Pull medium-sized images (good balance)
    docker pull catthehacker/ubuntu:act-latest
    docker pull catthehacker/ubuntu:act-22.04
    
    print_success "Runner images updated"
}

# Function to clean up
cleanup() {
    print_header "Cleaning Up"
    
    rm -rf /tmp/artifacts
    rm -rf /tmp/act-*
    docker system prune -f --filter label=act
    
    print_success "Cleanup completed"
}

# Function to check Docker/Colima setup
check_setup() {
    print_header "Checking Docker/Colima Setup"
    
    # Check Docker availability
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        return 1
    fi
    
    # Check Docker daemon
    if ! docker info &>/dev/null; then
        print_error "Docker daemon is not running"
        return 1
    fi
    
    print_success "Docker daemon is running"
    
    # Check Docker host
    echo "Docker Host: ${DOCKER_HOST:-default}"
    
    # Check if using Colima
    if [[ -n "$DOCKER_HOST" ]] && [[ "$DOCKER_HOST" == *"colima"* ]]; then
        print_warning "Using Colima Docker backend"
        
        # Check Colima status
        if command -v colima &> /dev/null; then
            echo "Colima status:"
            colima status 2>/dev/null || echo "Colima not running or accessible"
        fi
        
        # Check socket symlink
        if [[ -L "/var/run/docker.sock" ]]; then
            print_success "Docker socket symlink exists: $(readlink /var/run/docker.sock)"
        else
            print_warning "Docker socket symlink missing - may cause act issues"
            echo "To fix: sudo ln -sf ~/.colima/docker/docker.sock /var/run/docker.sock"
        fi
        
        # Check architecture
        echo "System architecture: $(uname -m)"
        if [[ $(uname -m) == "arm64" ]]; then
            print_warning "Apple Silicon detected - some workflows may have compatibility issues"
            echo "Recommendation: Use --container-architecture linux/amd64 with act"
        fi
    else
        print_success "Using standard Docker setup"
    fi
    
    # Check act version
    if command -v act &> /dev/null; then
        echo "Act version: $(act --version 2>/dev/null || echo 'unknown')"
        print_success "Act is installed"
    else
        print_error "Act is not installed - install with: brew install act"
    fi
}

# Handle command line arguments
case ${1:-menu} in
    "list")
        list_workflows
        ;;
    "ci")
        test_ci
        ;;
    "release")
        test_release
        ;;
    "job")
        if [[ -z "$2" ]]; then
            echo "Usage: $0 job <job_name>"
            exit 1
        fi
        test_job "$2"
        ;;
    "all")
        validate_syntax
        test_ci
        echo ""
        print_warning "Skipping release test (requires manual trigger)"
        print_success "All automated tests completed"
        ;;
    "validate")
        validate_syntax
        ;;
    "pull")
        pull_images
        ;;
    "clean")
        cleanup
        ;;
    "menu"|*)
        while true; do
            show_menu
            read -p "Choose an option (1-9): " choice
            case $choice in
                1)
                    list_workflows
                    ;;
                2)
                    test_ci
                    ;;
                3)
                    test_release
                    ;;
                4)
                    read -p "Enter job name: " job_name
                    test_job "$job_name"
                    ;;
                5)
                    validate_syntax
                    test_ci
                    print_warning "Release workflow requires manual inputs - test separately"
                    ;;
                6)
                    pull_images
                    ;;
                7)
                    cleanup
                    ;;
                8)
                    validate_syntax
                    ;;
                9)
                    check_setup
                    ;;
                10)
                    print_success "Goodbye!"
                    exit 0
                    ;;
                *)
                    print_error "Invalid option. Please choose 1-10."
                    ;;
            esac
            
            echo ""
            read -p "Press Enter to continue..."
        done
        ;;
esac