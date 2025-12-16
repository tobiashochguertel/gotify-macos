package main

import (
	"log"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"time"

	"github.com/gorilla/websocket"
	"github.com/tobiashochguertel/gotify-macos/internal/config"
	"github.com/tobiashochguertel/gotify-macos/internal/notification"
)

func main() {
	cfg := config.Parse()
	log.SetFlags(0)

	if cfg.ShowVersion {
		cfg.ShowVersionInfo()
	}

	if err := cfg.Validate(); err != nil {
		log.Fatal(err)
	}

	wsURL := url.URL{
		Scheme: "ws",
		Host:   cfg.Host,
		Path:   "/stream",
	}
	log.Printf("Websocket: Connecting to %s ...", wsURL.String())

	// TODO: GetAppIDs()

	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt)

	c, _, err := websocket.DefaultDialer.Dial(wsURL.String(), http.Header{"X-Gotify-Key": []string{cfg.Token}})
	if err != nil {
		log.Fatal("Websocket: failed to connect:", err)
	}
	defer c.Close()

	log.Printf("Websocket: connected!")

	done := make(chan struct{})

	go func() {
		defer close(done)
		for {
			notification.ParseGotifyNotification(c)
		}
	}()

	for {
		select {
		case <-done:
			return
		case <-interrupt:
			log.Println("Interrupted")

			// Cleanly close the connection by sending a close message and then
			// waiting (with timeout) for the server to close the connection.
			err := c.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			if err != nil {
				log.Println("Websocket: write close:", err)
				return
			}
			select {
			case <-done:
			case <-time.After(time.Second):
			}
			return
		}
	}
}
