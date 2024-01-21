#!/bin/bash

# Default image and container name
DEFAULT_IMAGE="nearprotocol/contract-builder:latest-amd64"
CONTAINER_NAME="sourcescan-builder-rust"

IMAGE_NAME=$DEFAULT_IMAGE
SCRIPT_TO_RUN=""

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--image) IMAGE_NAME="$2"; shift ;;
        -r|--run) SCRIPT_TO_RUN="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Extract the directory part of the script path
SCRIPT_DIR=$(dirname "$SCRIPT_TO_RUN")

# Logic to run the container with the specified script
if [ -n "$SCRIPT_TO_RUN" ]; then
    docker run \
        --name $CONTAINER_NAME \
        --mount type=bind,source="$(pwd)",target=/host \
        --rm -it $IMAGE_NAME \
        bash -c "cd /host/$SCRIPT_DIR && ./$(basename $SCRIPT_TO_RUN)"
else
    docker run \
        --name $CONTAINER_NAME \
        --mount type=bind,source="$(pwd)",target=/host \
        --rm -it $IMAGE_NAME \
        /bin/bash
fi
