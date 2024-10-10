#! /usr/bin/env bash

IMAGE_NAME="yfblock/rel4-dev"
IMAGE_VERSION="1.2"
CONTAINER_NAME="rel4_dev"
CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
FFOS_ROOT_DIR="$CURR_DIR"

function remove_container_if_exists() {
    local container="$1"
    if docker ps -a --format '{{.Names}}' | grep -q "${container}"; then
        echo "Removing existing ffos container: ${container}"
        docker stop "${container}" >/dev/null
        docker rm -v -f "${container}" 2>/dev/null
    fi
}

function main() {
    remove_container_if_exists ${CONTAINER_NAME}

    docker run -itd \
        --name "${CONTAINER_NAME}" \
        -v ${FFOS_ROOT_DIR}:/rel4 \
        -w /rel4 \
        ${IMAGE_NAME}:${IMAGE_VERSION} \
        /bin/bash
}

main "$@"
