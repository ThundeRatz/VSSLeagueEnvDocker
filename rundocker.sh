#!/usr/bin/env bash

DOCKER_IMAGE="thunderatz/firasim:latest"

# Executando o docker
docker run  -it \
            --rm \
            --privileged \
            --net=host \
            --env="DISPLAY" \
            --env="TERM" \
            $DOCKER_IMAGE
