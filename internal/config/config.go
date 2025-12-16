// Package config provides configuration management for gotify-macos
package config

import (
	"flag"
	"fmt"
	"os"
)

// Config holds the application configuration
type Config struct {
	Host        string
	Token       string
	ShowVersion bool
}

// Version information (set by build flags)
var (
	Version   = "dev"
	BuildTime = "unknown"
	Commit    = "unknown"
)

// Parse parses command line flags and returns the configuration
func Parse() *Config {
	cfg := &Config{}
	
	flag.StringVar(&cfg.Host, "host", "0.0.0.0:8080", "Gotify server address")
	flag.StringVar(&cfg.Token, "token", "", "Client token obtained from Gotify")
	flag.BoolVar(&cfg.ShowVersion, "version", false, "Show version information")
	
	flag.Parse()
	
	return cfg
}

// ShowVersionInfo displays version information and exits
func (c *Config) ShowVersionInfo() {
	fmt.Printf("gotify-macos version %s\n", Version)
	fmt.Printf("Built: %s\n", BuildTime)
	fmt.Printf("Commit: %s\n", Commit)
	os.Exit(0)
}

// Validate checks if the configuration is valid
func (c *Config) Validate() error {
	if c.Token == "" {
		return fmt.Errorf("client token is required. Use --token flag to provide it")
	}
	return nil
}