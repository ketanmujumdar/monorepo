#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_message "$RED" "Error: kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Function to check cluster connectivity
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_message "$RED" "Error: Cannot connect to Kubernetes cluster"
        exit 1
    fi
}

# Function to create namespaces
apply_namespaces() {
    print_message "$GREEN" "Creating namespaces..."
    # Apply namespace files first
    find . -type f -name "*.yaml" -exec grep -l "kind: Namespace" {} \; | while read file; do
        print_message "$YELLOW" "Applying namespace from $file"
        kubectl apply -f "$file"
    done
}

# Function to apply CRDs and cluster resources
apply_cluster_resources() {
    print_message "$GREEN" "Applying cluster-wide resources..."
    
    # Apply CRDs first
    find . -type f -name "*.yaml" -exec grep -l "kind: CustomResourceDefinition" {} \; | while read file; do
        print_message "$YELLOW" "Applying CRD from $file"
        kubectl apply -f "$file"
    done

    # Apply RBAC resources
    for resource in ClusterRole ClusterRoleBinding ServiceAccount; do
        find . -type f -name "*.yaml" -exec grep -l "kind: $resource" {} \; | while read file; do
            print_message "$YELLOW" "Applying $resource from $file"
            kubectl apply -f "$file"
        done
    done
}

# Function to apply ConfigMaps and Secrets
apply_configs() {
    print_message "$GREEN" "Applying ConfigMaps and Secrets..."
    for resource in ConfigMap Secret; do
        find . -type f -name "*.yaml" -exec grep -l "kind: $resource" {} \; | while read file; do
            print_message "$YELLOW" "Applying $resource from $file"
            kubectl apply -f "$file"
        done
    done
}

# Function to apply remaining resources
apply_remaining() {
    print_message "$GREEN" "Applying remaining resources..."
    find . -type f -name "*.yaml" | while read file; do
        if ! grep -q "kind: Namespace\|kind: CustomResourceDefinition\|kind: ClusterRole\|kind: ClusterRoleBinding\|kind: ConfigMap\|kind: Secret" "$file"; then
            print_message "$YELLOW" "Applying $file"
            kubectl apply -f "$file"
        fi
    done
}

# Function to verify deployments
verify_deployments() {
    print_message "$GREEN" "Verifying deployments..."
    kubectl get deployments --all-namespaces
    
    # Check if any deployments failed
    local failed_deployments=$(kubectl get deployments --all-namespaces -o json | jq -r '.items[] | select(.status.availableReplicas == null or .status.availableReplicas == 0) | .metadata.name')
    
    if [ ! -z "$failed_deployments" ]; then
        print_message "$RED" "Warning: Some deployments may have failed to start:"
        echo "$failed_deployments"
    fi
}

# Main execution
main() {
    print_message "$GREEN" "Starting Kubernetes resource application..."
    
    # Check prerequisites
    check_kubectl
    check_cluster
    
    # Get target directory
    local target_dir="."
    if [ ! -z "$1" ]; then
        target_dir="$1"
    fi
    
    # Change to target directory
    cd "$target_dir" || exit 1
    
    # Apply resources in order
    apply_namespaces
    
    # Wait for namespaces to be ready
    sleep 5
    
    apply_cluster_resources
    
    # Wait for cluster resources to be ready
    sleep 5
    
    apply_configs
    
    # Wait for configs to be ready
    sleep 5
    
    apply_remaining
    
    # Verify deployments
    sleep 10
    verify_deployments
    
    print_message "$GREEN" "Resource application complete!"
}

# Execute main function with directory argument
main "$1"