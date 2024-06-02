#!/bin/bash

CONTAINER_NAME=debian-testing
IMAGE_NAME=debian:testing
TEMP_DIR=$(mktemp -d)

cp -r "$(pwd)"/* "$TEMP_DIR"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Container $CONTAINER_NAME exists."
    
    if [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
        docker start $CONTAINER_NAME
    fi

    docker exec "$CONTAINER_NAME" rm -rf /work/*

    docker cp "$TEMP_DIR" "$CONTAINER_NAME":/work

else
    echo "Creating and starting new container $CONTAINER_NAME."
    
    docker run --privileged -d --name "$CONTAINER_NAME" "$IMAGE_NAME" sleep infinity

    docker cp "$TEMP_DIR" "$CONTAINER_NAME":/work
fi

rm -rf "$TEMP_DIR"

docker exec -it "$CONTAINER_NAME" /bin/bash /run.sh
docker cp "$CONTAINER_NAME":/work/builds "$(pwd)" 
