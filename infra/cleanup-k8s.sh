#!/bin/bash

echo "Starting Kubernetes cluster cleanup..."

# Function to delete resources with timeout
delete_with_timeout() {
    local resource_type=$1
    local namespace=$2
    local timeout=30s

    if [ -n "$namespace" ]; then
        echo "Deleting $resource_type in namespace $namespace..."
        kubectl delete $resource_type --all -n $namespace --timeout=$timeout
    else
        echo "Deleting $resource_type across all namespaces..."
        kubectl delete $resource_type --all --all-namespaces --timeout=$timeout
    fi
}

# Function to force delete namespaces that are stuck
force_delete_namespace() {
    local namespace=$1
    echo "Force deleting namespace $namespace..."
    kubectl get namespace $namespace -o json | \
    jq '.spec.finalizers = []' | \
    kubectl replace --raw "/api/v1/namespaces/$namespace/finalize" -f -
}

# Delete resources in specific order
echo "Deleting Deployments..."
kubectl delete deployments --all --all-namespaces

echo "Deleting Services..."
kubectl delete services --all --all-namespaces --force

echo "Deleting StatefulSets..."
kubectl delete statefulsets --all --all-namespaces

echo "Deleting DaemonSets..."
kubectl delete daemonsets --all --all-namespaces

echo "Deleting ReplicaSets..."
kubectl delete replicasets --all --all-namespaces

echo "Deleting Pods..."
kubectl delete pods --all --all-namespaces --force

echo "Deleting ConfigMaps..."
kubectl delete configmaps --all --all-namespaces

echo "Deleting Secrets..."
kubectl delete secrets --all --all-namespaces

echo "Deleting PersistentVolumeClaims..."
kubectl delete pvc --all --all-namespaces

echo "Deleting PersistentVolumes..."
kubectl delete pv --all

echo "Deleting ServiceAccounts..."
kubectl delete serviceaccounts --all --all-namespaces

echo "Deleting ClusterRoles..."
kubectl delete clusterroles --all

echo "Deleting ClusterRoleBindings..."
kubectl delete clusterrolebindings --all

echo "Deleting Roles..."
kubectl delete roles --all --all-namespaces

echo "Deleting RoleBindings..."
kubectl delete rolebindings --all --all-namespaces

# Get list of all namespaces except default, kube-system, and kube-public
NAMESPACES=$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | \
             grep -v '^kube-system$' | \
             grep -v '^default$' | \
             grep -v '^kube-public$' | \
             grep -v '^kube-node-lease$')

# Delete each namespace
for ns in $NAMESPACES; do
    echo "Deleting namespace $ns..."
    kubectl delete namespace $ns --timeout=30s
    
    # Check if namespace is stuck in Terminating state
    sleep 5
    if kubectl get namespace $ns > /dev/null 2>&1; then
        echo "Namespace $ns is stuck, attempting force delete..."
        force_delete_namespace $ns
    fi
done

echo "Cleanup complete!"

# Optional: Verify no resources remain (except system resources)
echo "Verifying cleanup..."
kubectl get all --all-namespaces
echo "Done!"