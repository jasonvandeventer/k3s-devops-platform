package main

import (
    "fmt"
    "net/http"
    "os"
    "time"
)

func main() {
    version := getenv("VERSION", "dev")
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        host, _ := os.Hostname()
        fmt.Fprintf(w, "<h1>k3s demo app</h1><p>version: %s</p><p>host: %s</p><p>time: %s</p>,
            version, host, time.Now().Format(time.RFC3339))
    })
    addr := ":8080"
    fmt.Println("listening on", addr, "version", version)
    http.ListenAndServe(addr, nil)
}

func getenv(k, def string) string {
    if v := os.Getenv(k); v != "" {
        return v
    }
    return def
}
