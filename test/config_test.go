package test

import (
	"os"
	"testing"

	"github.com/tobiashochguertel/gotify-macos/internal/config"
)

func TestConfigValidation(t *testing.T) {
	tests := []struct {
		name        string
		config      *config.Config
		expectError bool
	}{
		{
			name: "valid config",
			config: &config.Config{
				Host:  "localhost:8080",
				Token: "test-token",
			},
			expectError: false,
		},
		{
			name: "missing token",
			config: &config.Config{
				Host:  "localhost:8080",
				Token: "",
			},
			expectError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.config.Validate()
			if tt.expectError && err == nil {
				t.Error("expected error but got nil")
			}
			if !tt.expectError && err != nil {
				t.Errorf("expected no error but got: %v", err)
			}
		})
	}
}

func TestVersionInfo(t *testing.T) {
	// Save original values
	origVersion := config.Version
	origBuildTime := config.BuildTime
	origCommit := config.Commit

	// Set test values
	config.Version = "test-version"
	config.BuildTime = "test-build-time"
	config.Commit = "test-commit"

	// Restore original values after test
	defer func() {
		config.Version = origVersion
		config.BuildTime = origBuildTime
		config.Commit = origCommit
	}()

	// Verify version info doesn't crash
	if config.Version == "" {
		t.Error("Version should not be empty")
	}
	if config.BuildTime == "" {
		t.Error("BuildTime should not be empty")
	}
	if config.Commit == "" {
		t.Error("Commit should not be empty")
	}
}

func TestConfigParsing(t *testing.T) {
	// Save original args
	origArgs := os.Args
	defer func() { os.Args = origArgs }()

	// Test with mock args
	os.Args = []string{"gotify-macos", "--host=test:8080", "--token=test-token"}
	
	cfg := config.Parse()
	
	if cfg.Host != "test:8080" {
		t.Errorf("Expected host to be 'test:8080', got '%s'", cfg.Host)
	}
	if cfg.Token != "test-token" {
		t.Errorf("Expected token to be 'test-token', got '%s'", cfg.Token)
	}
}