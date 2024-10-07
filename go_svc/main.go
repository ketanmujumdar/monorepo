package main

import (
	"encoding/json"
	"log"
	"net/http"
)

// Response represents the structure of our JSON response
type Response struct {
	Message string `json:"message"`
}

func main() {
	// Define the API route
	http.HandleFunc("/golang", handleAPI)

	// Start the server
	log.Println("Server starting on port 8081...")
	if err := http.ListenAndServe(":8081", nil); err != nil {
		log.Fatal(err)
	}
}

func handleAPI(w http.ResponseWriter, r *http.Request) {
	// Create a response
	response := Response{
		Message: "Hello from the GO API!",
	}

	// Set the content type to JSON
	w.Header().Set("Content-Type", "application/json")

	// Encode the response as JSON and write it to the response writer
	json.NewEncoder(w).Encode(response)
}
