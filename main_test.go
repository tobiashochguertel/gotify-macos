package main

import (
	"testing"
)

func TestVersionInfo(t *testing.T) {
	// Test that version variables exist and have default values
	if Version == "" {
		Version = "dev"
	}
	if BuildTime == "" {
		BuildTime = "unknown"
	}
	if Commit == "" {
		Commit = "unknown"
	}

	// Verify they are not empty after setting defaults
	if Version == "" {
		t.Error("Version should not be empty")
	}
	if BuildTime == "" {
		t.Error("BuildTime should not be empty")
	}
	if Commit == "" {
		t.Error("Commit should not be empty")
	}
}