#!/bin/bash

YELLOW_BACK="\e[43m"
GREEN_BACK="\e[42m"
BOLD="\e[1m"
RESET="\e[0m"

if [ -e "/work" ]; then
    cd /work || exit
    /bin/bash build.sh

else
    CONTAINER_NAME=strawberryos-iso-builder
    IMAGE_NAME=debian:testing
    TEMP_DIR=$(mktemp -d)

    cp -r "$(pwd)"/* "$TEMP_DIR"

    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        echo -e "${YELLOW_BACK}${BOLD}  INFO  ${RESET}  Container '$CONTAINER_NAME' exists"
        if [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
            docker start $CONTAINER_NAME
        fi

        docker exec "$CONTAINER_NAME" rm -rf /work/
        docker cp "$TEMP_DIR" "$CONTAINER_NAME":/work

    else
        echo -e "${YELLOW_BACK}${BOLD}  INFO  ${RESET}  Creating and starting new container '$CONTAINER_NAME'"
        
        docker run --privileged -d --name "$CONTAINER_NAME" "$IMAGE_NAME" sleep infinity

        docker cp "$TEMP_DIR" "$CONTAINER_NAME":/work

        echo -e "${GREEN_BACK}${BOLD}   OK  ${RESET}  Container '$CONTAINER_NAME' successfully created"
    fi

    rm -rf "$TEMP_DIR"

    echo -e "${YELLOW_BACK}${BOLD}  INFO  ${RESET}  Starting live iso build process"

    docker exec -it "$CONTAINER_NAME" /bin/bash /work/run_container.sh
    docker cp "$CONTAINER_NAME":/work/builds "$(pwd)" 

fi