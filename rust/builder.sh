#!/bin/bash

# Default image and container names
DEFAULT_IMAGE="nearprotocol/contract-builder:latest-amd64"
CONTAINER_NAME="sourcescan-builder-rust"

IMAGE_NAME=$DEFAULT_IMAGE
SCRIPT_TO_RUN=""

# Function to check if a container exists
container_exists() {
  docker ps -a --format '{{.Names}}' | grep -qw $CONTAINER_NAME
}

# Function to get the image of an existing container
get_container_image() {
  docker inspect --format='{{.Config.Image}}' $CONTAINER_NAME
}

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

# Check if the container exists
if container_exists; then
  echo "Container $CONTAINER_NAME already exists."
  
  # Check if the existing container was created with a different image
  if [ "$(get_container_image)" != "$IMAGE_NAME" ]; then
    echo "Existing container was created with a different image. Updating image..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME

    # Check if the container was successfully removed
    if ! container_exists; then
      echo "Container successfully removed. Creating a new one..."
      # Logic for creating a new container
      if [ -n "$SCRIPT_TO_RUN" ]; then
        docker run \
            --name $CONTAINER_NAME \
            --mount type=bind,source="$(pwd)",target=/host \
            --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
            -it $IMAGE_NAME \
            bash -c "cd /host/$SCRIPT_DIR && ./$(basename $SCRIPT_TO_RUN)"
      else
        docker run \
            --name $CONTAINER_NAME \
            --mount type=bind,source="$(pwd)",target=/host \
            --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
            -it $IMAGE_NAME \
            /bin/bash
      fi
    else
      echo "Failed to remove the container. Please check Docker status."
      exit 1
    fi
  else
    # Logic for reusing existing container
    if [ -n "$SCRIPT_TO_RUN" ]; then
      docker start $CONTAINER_NAME
      docker exec -it $CONTAINER_NAME bash -c "cd /host/$SCRIPT_DIR && ./$(basename $SCRIPT_TO_RUN)"
    else
      docker start -ai $CONTAINER_NAME
    fi
  fi
else
  echo "Creating a new container..."
  # Logic for creating a new container
  if [ -n "$SCRIPT_TO_RUN" ]; then
    docker run \
        --name $CONTAINER_NAME \
        --mount type=bind,source="$(pwd)",target=/host \
        --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        -it $IMAGE_NAME \
        bash -c "cd /host/$SCRIPT_DIR && ./$(basename $SCRIPT_TO_RUN)"
  else
    docker run \
        --name $CONTAINER_NAME \
        --mount type=bind,source="$(pwd)",target=/host \
        --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        -it $IMAGE_NAME \
        /bin/bash
  fi
fi
