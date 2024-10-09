package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

// Response represents the structure of our JSON response
type Response struct {
	Message     string `json:"message"`
	PHPResponse string `json:"php_response,omitempty"`
}

func main() {

	// Define the API route
	http.HandleFunc("/", handleAPI)

	// Start the server
	log.Println("Server starting on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

func handleAPI(w http.ResponseWriter, r *http.Request) {

	phpUrl := os.Getenv("PHP_SERVICE_URL")
	response := Response{
		Message: "Hello from the GO API! This is a stable env API, calling PHP Stable API",
	}

	// Call PHP API
	url := phpUrl + "/php_svc"
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("Error calling PHP API: %v", err)
		response.PHPResponse = fmt.Sprintf("Error calling PHP API: %v", err)
	} else {
		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("Error reading PHP API response: %v", err)
			response.PHPResponse = fmt.Sprintf("Error reading PHP API response: %v", err)
		} else {
			response.PHPResponse = string(body)
		}
	}

	// Set the content type to JSON
	w.Header().Set("Content-Type", "application/json")

	// Encode the response as JSON and write it to the response writer
	if err := json.NewEncoder(w).Encode(response); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
}
