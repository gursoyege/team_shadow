#!/bin/bash
# Usage: ./run.sh -i (or --image) my-image -n (or --name) my-container (if you want container to be removed after exit)-t (or --temp)

set -e
set -u

IMAGE_NAME=""
CONTAINER_NAME=""
TEMP_MODE=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--image) 
            if [[ -n "$2" && "$2" != -* ]]; then
                IMAGE_NAME="$2"
                shift
            else
                echo "Error: You need to specify an image name after -i or --image."
                exit 1
            fi
            ;;
        -n|--name)
            if [[ -n "$2" && "$2" != -* ]]; then
                CONTAINER_NAME="$2"
                shift
            else
                echo "Error: You need to specify a container name after -n or --name."
                exit 1
            fi
            ;;
        -t|--temp)
            TEMP_MODE=true
            ;;
        *) 
            echo "Unknown parameter passed: $1"
            exit 1 
            ;;
    esac
    shift
done

# Check required arguments
if [[ -z "$IMAGE_NAME" ]]; then
    echo "Error: You need to specify an image name using -i or --image."
    exit 1
fi

if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Error: You need to specify a container name using -n or --name."
    exit 1
fi

# Allow X11 access temporarily
export DISPLAY=${DISPLAY:-:0}
echo "Setting display to $DISPLAY"
xhost +local:root

# Add --rm flag only if temp mode is enabled
RM_FLAG=""
if [[ "$TEMP_MODE" = true ]]; then
    RM_FLAG="--rm"
fi

docker run $RM_FLAG -it \
  --entrypoint /bin/bash \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  --gpus all \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  --network=host \
  --name="$CONTAINER_NAME" \
  "$IMAGE_NAME"

xhost -local:root

