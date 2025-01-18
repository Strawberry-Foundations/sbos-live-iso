#!/bin/bash

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

# Constants
declare -r CONTAINER_NAME="strawberryos-iso-builder"
declare -r IMAGE_NAME="debian:testing"
declare -r WORK_DIR="/work"

# Color definitions
declare -A COLORS=(
    ["yellow_back"]="\e[43m"
    ["green_back"]="\e[42m"
    ["bold"]="\e[1m"
    ["reset"]="\e[0m"
)

# Logging functions
log_info() {
    echo -e "${COLORS[yellow_back]}${COLORS[bold]}  INFO  ${COLORS[reset]}  $1"
}

log_success() {
    echo -e "${COLORS[green_back]}${COLORS[bold]}   OK   ${COLORS[reset]}  $1"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    exit $exit_code
}

trap cleanup EXIT

# Main execution
if [[ -e "$WORK_DIR" ]]; then
    cd "$WORK_DIR" || exit 1
    /bin/bash build.sh
else
    TEMP_DIR=$(mktemp -d)
    cp -r "$(pwd)"/* "$TEMP_DIR"

    if docker ps -aq -f name="$CONTAINER_NAME" > /dev/null; then
        log_info "Container '$CONTAINER_NAME' exists"
        if docker ps -aq -f status=exited -f name="$CONTAINER_NAME" > /dev/null; then
            docker start "$CONTAINER_NAME"
        fi

        docker exec "$CONTAINER_NAME" rm -rf "$WORK_DIR/"
        docker cp "$TEMP_DIR" "$CONTAINER_NAME:$WORK_DIR"
    else
        log_info "Creating and starting new container '$CONTAINER_NAME'"
        docker run --privileged -d \
            --name "$CONTAINER_NAME" \
            "$IMAGE_NAME" \
            sleep infinity

        docker cp "$TEMP_DIR" "$CONTAINER_NAME:$WORK_DIR"
        log_success "Container '$CONTAINER_NAME' successfully created"
    fi

    log_info "Starting live iso build process"
    docker exec -it "$CONTAINER_NAME" /bin/bash "$WORK_DIR/run_container.sh"
    docker cp "$CONTAINER_NAME:$WORK_DIR/builds" "$(pwd)"
fi