package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

type Response struct {
	Message string `json:"message"`
}

var services map[string]string

func init() {
	services = map[string]string{
		"go":     getEnv("GO_SERVICE_URL", "http://go-api-service.default.svc.cluster.local:8080"),
		"python": getEnv("PYTHON_SERVICE_URL", "http://python-api-service.default.svc.cluster.local:8080"),
		"php":    getEnv("PHP_SERVICE_URL", "http://php-api-service.default.svc.cluster.local:8080"),
	}
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

func main() {
	http.HandleFunc("/gateway/", handleGateway)
	http.HandleFunc("/all", handleAll)
	log.Println("Gateway starting on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleGateway(w http.ResponseWriter, r *http.Request) {
	service := r.URL.Path[len("/gateway/"):]
	if url, ok := services[service]; ok {
		proxyRequest(w, url)
	} else {
		http.Error(w, "Service not found", http.StatusNotFound)
	}
}

func handleAll(w http.ResponseWriter, r *http.Request) {
	responses := make(map[string]interface{})
	for service, url := range services {
		resp, err := http.Get(url)
		if err != nil {
			responses[service] = fmt.Sprintf("Error: %v", err)
			continue
		}
		defer resp.Body.Close()

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			responses[service] = fmt.Sprintf("Error reading response: %v", err)
			continue
		}

		var result interface{}
		err = json.Unmarshal(body, &result)
		if err != nil {
			responses[service] = fmt.Sprintf("Error parsing response: %v", err)
			continue
		}

		responses[service] = result
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(responses)
}

func proxyRequest(w http.ResponseWriter, url string) {
	resp, err := http.Get(url)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error: %v", err), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error reading response: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(body)
}
