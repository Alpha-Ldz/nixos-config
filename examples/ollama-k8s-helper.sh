#!/usr/bin/env bash

# Script helper pour gérer Ollama sur K3S
# Usage: ./ollama-k8s-helper.sh [command]

set -e

NAMESPACE="llm"
POD_SELECTOR="app=ollama"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
error() { echo -e "${RED}$1${NC}" >&2; exit 1; }

# Get Ollama pod name
get_pod() {
    kubectl get pods -n $NAMESPACE -l $POD_SELECTOR -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

# Wait for pod to be ready
wait_for_pod() {
    info "Waiting for Ollama pod to be ready..."
    kubectl wait --for=condition=ready pod -l $POD_SELECTOR -n $NAMESPACE --timeout=300s
}

# Deploy Ollama
deploy() {
    info "Deploying Ollama to K3S..."
    kubectl apply -f ollama-k8s-deployment.yaml
    wait_for_pod
    info "Ollama deployed successfully!"
    show_status
}

# Remove Ollama
remove() {
    warn "Removing Ollama deployment..."
    kubectl delete -f ollama-k8s-deployment.yaml 2>/dev/null || true
    info "Ollama removed."
}

# Show status
show_status() {
    info "\n=== Ollama Status ==="

    echo -e "\nPods:"
    kubectl get pods -n $NAMESPACE -l $POD_SELECTOR

    echo -e "\nService:"
    kubectl get svc -n $NAMESPACE ollama

    POD=$(get_pod)
    if [ -n "$POD" ]; then
        echo -e "\nGPU Allocation:"
        kubectl describe pod -n $NAMESPACE $POD | grep -A 5 "Limits:"

        echo -e "\nAccess Ollama at:"
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
        NODE_PORT=$(kubectl get svc -n $NAMESPACE ollama -o jsonpath='{.spec.ports[0].nodePort}')
        echo "  http://${NODE_IP}:${NODE_PORT}"
    fi
}

# List models in Ollama
list_models() {
    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    info "Models in Ollama:"
    kubectl exec -n $NAMESPACE $POD -- ollama list
}

# Pull a model
pull_model() {
    [ -z "$1" ] && error "Usage: $0 pull <model-name>"

    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    info "Pulling model: $1"
    kubectl exec -n $NAMESPACE $POD -ti -- ollama pull "$1"
}

# Remove a model
remove_model() {
    [ -z "$1" ] && error "Usage: $0 remove-model <model-name>"

    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    warn "Removing model: $1"
    kubectl exec -n $NAMESPACE $POD -- ollama rm "$1"
}

# Run a prompt
run_prompt() {
    [ -z "$1" ] && error "Usage: $0 run <model-name> [prompt]"

    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    MODEL=$1
    PROMPT=${2:-"Hello, who are you?"}

    info "Running prompt on $MODEL..."
    kubectl exec -n $NAMESPACE $POD -ti -- ollama run "$MODEL" "$PROMPT"
}

# Interactive shell
shell() {
    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    info "Opening shell in Ollama pod..."
    kubectl exec -n $NAMESPACE $POD -ti -- /bin/bash
}

# View logs
logs() {
    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    kubectl logs -n $NAMESPACE $POD -f
}

# Test GPU
test_gpu() {
    POD=$(get_pod)
    [ -z "$POD" ] && error "No Ollama pod found"

    info "Testing GPU access..."
    kubectl exec -n $NAMESPACE $POD -- nvidia-smi
}

# Quick test with a small model
quick_test() {
    info "Running quick test with tinyllama..."
    pull_model "tinyllama"
    run_prompt "tinyllama" "Write a haiku about kubernetes"
}

show_usage() {
    cat << 'EOF'
Ollama K8S Helper Script

Usage: ./ollama-k8s-helper.sh [COMMAND]

Commands:
    deploy          Deploy Ollama to K3S
    remove          Remove Ollama deployment
    status          Show deployment status

    list            List installed models
    pull MODEL      Pull a model (e.g., llama2, mistral)
    remove-model    Remove a model
    run MODEL [PROMPT]  Run a model with optional prompt

    shell           Open interactive shell in Ollama pod
    logs            View Ollama logs
    test-gpu        Test GPU access
    quick-test      Quick test with tinyllama

Examples:
    # Deploy Ollama
    ./ollama-k8s-helper.sh deploy

    # Pull and run a model
    ./ollama-k8s-helper.sh pull llama2
    ./ollama-k8s-helper.sh run llama2 "Explain Docker in simple terms"

    # Check GPU
    ./ollama-k8s-helper.sh test-gpu

Popular models:
    - tinyllama (1.1B) - Fastest, good for testing
    - llama2:7b (7B) - Good balance, needs ~8GB VRAM
    - mistral:7b (7B) - High quality, needs ~8GB VRAM
    - codellama:7b (7B) - Code generation, needs ~8GB VRAM
    - llama2:13b (13B) - Better quality, needs ~16GB VRAM
    - mixtral:8x7b (47B MoE) - High quality, needs ~24GB VRAM

EOF
}

# Main
case "${1:-}" in
    deploy)         deploy ;;
    remove)         remove ;;
    status)         show_status ;;
    list)           list_models ;;
    pull)           pull_model "$2" ;;
    remove-model)   remove_model "$2" ;;
    run)            run_prompt "$2" "$3" ;;
    shell)          shell ;;
    logs)           logs ;;
    test-gpu)       test_gpu ;;
    quick-test)     quick_test ;;
    help|--help|-h) show_usage ;;
    *)              show_usage; exit 1 ;;
esac
