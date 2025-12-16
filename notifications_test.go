package main

import (
	"encoding/json"
	"testing"
)

func TestGotifyMessageUnmarshaling(t *testing.T) {
	jsonData := `{
		"appid": 1,
		"date": "2024-01-01T10:00:00Z",
		"id": 123,
		"message": "Test message",
		"priority": 5,
		"title": "Test Title"
	}`

	var msg GotifyMessage
	err := json.Unmarshal([]byte(jsonData), &msg)
	if err != nil {
		t.Fatalf("Failed to unmarshal JSON: %v", err)
	}

	if msg.AppID != 1 {
		t.Errorf("Expected AppID to be 1, got %d", msg.AppID)
	}
	if msg.ID != 123 {
		t.Errorf("Expected ID to be 123, got %d", msg.ID)
	}
	if msg.Title != "Test Title" {
		t.Errorf("Expected Title to be 'Test Title', got %s", msg.Title)
	}
	if msg.Message != "Test message" {
		t.Errorf("Expected Message to be 'Test message', got %s", msg.Message)
	}
	if msg.Priority != 5 {
		t.Errorf("Expected Priority to be 5, got %d", msg.Priority)
	}
}

func TestGotifyApplicationUnmarshaling(t *testing.T) {
	jsonData := `{
		"id": 1,
		"token": "test-token",
		"name": "Test App",
		"description": "A test application",
		"internal": false,
		"image": "test-image.png"
	}`

	var app GotifyApplication
	err := json.Unmarshal([]byte(jsonData), &app)
	if err != nil {
		t.Fatalf("Failed to unmarshal JSON: %v", err)
	}

	if app.ID != 1 {
		t.Errorf("Expected ID to be 1, got %d", app.ID)
	}
	if app.Name != "Test App" {
		t.Errorf("Expected Name to be 'Test App', got %s", app.Name)
	}
	if app.AppToken != "test-token" {
		t.Errorf("Expected AppToken to be 'test-token', got %s", app.AppToken)
	}
}