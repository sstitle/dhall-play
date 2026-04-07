package main

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"os"
)

//go:embed config.json
var configJSON []byte

type config struct {
	Greeting string `json:"greeting"`
	Name     string `json:"name"`
	Style    string `json:"style"`
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
	out, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		panic(err)
	}
	fmt.Println()
	fmt.Println("JSON:")
	fmt.Println(string(out))
}
