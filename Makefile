# Makefile for gotify-macos

# Binary name
BINARY_NAME=gotify-macos

# Build directory
BUILD_DIR=bin

# Version
VERSION?=$(shell git describe --tags --always --dirty)
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
COMMIT=$(shell git rev-parse HEAD)

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Ldflags
LDFLAGS=-ldflags "-X github.com/tobiashochguertel/gotify-macos/internal/config.Version=$(VERSION) -X github.com/tobiashochguertel/gotify-macos/internal/config.BuildTime=$(BUILD_TIME) -X github.com/tobiashochguertel/gotify-macos/internal/config.Commit=$(COMMIT)"

.PHONY: all build clean test deps help test-cross-platform test-workflows validate-workflows

# Default target
all: clean deps test build

# Build the binary
build:
	mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/gotify-macos

# Build for multiple platforms
build-all: clean deps
	mkdir -p $(BUILD_DIR)
	# Windows
	GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe ./cmd/gotify-macos
	GOOS=windows GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe ./cmd/gotify-macos
	# macOS
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 ./cmd/gotify-macos
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 ./cmd/gotify-macos
	# Linux
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./cmd/gotify-macos
	GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 ./cmd/gotify-macos

# Install the binary
install: deps
	$(GOCMD) install $(LDFLAGS) ./cmd/gotify-macos

# Clean build directory
clean:
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)

# Run tests
test:
	$(GOTEST) -v ./...

# Download dependencies
deps:
	$(GOMOD) download
	$(GOMOD) tidy

# Run the application
run: build
	./$(BUILD_DIR)/$(BINARY_NAME)

# Test cross-platform builds using Docker
test-cross-platform:
	./scripts/test-cross-platform.sh

# Test GitHub Actions workflows locally using act
test-workflows:
	./scripts/test-workflows.sh

# Quick workflow validation
validate-workflows:
	./scripts/test-workflows.sh validate

# Show help
help:
	@echo "Available targets:"
	@echo "  all               - Clean, download deps, test, and build"
	@echo "  build             - Build the binary for current platform"
	@echo "  build-all         - Build binaries for all supported platforms"
	@echo "  install           - Install using go install"
	@echo "  clean             - Clean build directory"
	@echo "  test              - Run unit tests"
	@echo "  test-cross-platform - Test builds across platforms using Docker"
	@echo "  test-workflows    - Test GitHub Actions workflows locally with act"
	@echo "  validate-workflows - Validate workflow syntax"
	@echo "  deps              - Download and tidy dependencies"
	@echo "  run               - Build and run the application"
	@echo "  help              - Show this help message"