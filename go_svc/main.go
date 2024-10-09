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
		Message: "Hello from the GO API! This is a stable env API, calling PHP Stable API",
	}

	//call PHP API
	// set request URL and port in environment

	url := os.Getenv("PHP_API_URL")
	port := os.Getenv("PHP_API_PORT")

	// create request
	req, err := http.NewRequest("GET", url+":"+port+"/php-api", nil)
	if err != nil {
		log.Fatal(err)
	}

	defer req.Body.Close()

	body, err := io.ReadAll(req.Body)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(string(body))

	// Set the content type to JSON
	w.Header().Set("Content-Type", "application/json")

	// Encode the response as JSON and write it to the response writer
	json.NewEncoder(w).Encode(response)
}
