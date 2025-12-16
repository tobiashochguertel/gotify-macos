// Package notification provides cross-platform desktop notifications and Gotify message handling
package notification

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
	"github.com/gen2brain/beeep"
)

// TODO: Import these from gotify/server
type GotifyMessage struct {
	AppID    int    `json:"appid"`
	Date     string `json:"date"`
	ID       int    `json:"id"`
	Message  string `json:"message"`
	Priority int    `json:"priority"`
	Title    string `json:"title"`
}

type GotifyApplication struct {
	ID          int    `json:"id"`
	AppToken    string `json:"token"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Internal    bool   `json:"internal"`
	Image       string `json:"image"`
}

// SendNotification sends a desktop notification with the given title and message
func SendNotification(title string, message string) {
	err := beeep.Notify(title, message, "")
	if err != nil {
		log.Printf("Failed to send notification: %v", err)
	}
}

// GetAppIDs retrieves the list of Gotify applications from the server
func GetAppIDs(host, token string) []GotifyApplication {
	appEndpoint := fmt.Sprintf("http://%s/application?token=%s", host, token)

	res, err := http.Get(appEndpoint)
	if err != nil {
		log.Print("Could not retrieve list of Gotify applications:", err)
	}

	body, err := io.ReadAll(res.Body)
	if err != nil {
		log.Fatal("Invalid response for application list:", err)
	}

	var apps []GotifyApplication
	if err := json.Unmarshal(body, &apps); err != nil {
		panic("GetAppIDs: Failed to decode JSON")
	}
	return apps
}

// ParseGotifyNotification reads and processes a Gotify notification from the websocket connection
func ParseGotifyNotification(c *websocket.Conn) {
	_, message, err := c.ReadMessage()
	if err != nil {
		log.Println("Websocket: read error:", err)
		return
	}

	var msg GotifyMessage
	if err := json.Unmarshal(message, &msg); err != nil {
		panic("GotifyMessage: Failed to decode JSON")
	}
	SendNotification(msg.Title, msg.Message)
}
