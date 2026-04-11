package main

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

//go:embed config.json
var configJSON []byte

type config struct {
	Greeting string   `json:"greeting"`
	Name     string   `json:"name"`
	Style    string   `json:"style"`
	Tags     []string `json:"tags"`
	Note     string   `json:"note,omitempty"`
}

func main() {
	var c config
	if err := json.Unmarshal(configJSON, &c); err != nil {
		fmt.Fprintf(os.Stderr, "parse config: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("Hello from Go (JSON embedded at build time from Dhall)")
	fmt.Println()
	fmt.Printf("  %s, %s! (style: %s)\n", c.Greeting, c.Name, c.Style)
	if len(c.Tags) > 0 {
		fmt.Println("  tags:")
		for _, t := range c.Tags {
			fmt.Printf("    - %s\n", t)
		}
	}
	if strings.TrimSpace(c.Note) != "" {
		fmt.Printf("  note: %s\n", c.Note)
	}
	out, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		panic(err)
	}
	fmt.Println()
	fmt.Println("JSON:")
	fmt.Println(string(out))
}
