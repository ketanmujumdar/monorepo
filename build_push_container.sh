#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Docker Hub username
USERNAME="ketanmujumdar"

# Function to get container name from folder name
get_container_name() {
    case $1 in
        "go_svc") echo "go-api" ;;
        "python_svc") echo "python-api" ;;
        "php_svc") echo "php-api" ;;
        "gateway") echo "gateway" ;;
        *) echo "$1" ;;  # Default to folder name if not in the list
    esac
}

# Function to build and push an image
build_and_push() {
    folder_name=$1
    container_name=$(get_container_name "$folder_name")
    echo "Building $container_name from $folder_name..."
    docker build -t "$USERNAME/$container_name:latest" -f "$folder_name/Dockerfile" "$folder_name"
    echo "Pushing $container_name..."
    docker push "$USERNAME/$container_name:latest"
}

# Check if logged in to Docker Hub
if ! docker info | grep -q "Username: $USERNAME"; then
    echo "Please log in to Docker Hub:"
    docker login
fi

# Loop through services
for folder_name in go_svc python_svc php_svc gateway
do
    if [ -d "$folder_name" ] && [ -f "$folder_name/Dockerfile" ]; then
        build_and_push "$folder_name"
    else
        echo "Warning: $folder_name directory or Dockerfile not found. Skipping..."
    fi
done

echo "All images built and pushed successfully!"