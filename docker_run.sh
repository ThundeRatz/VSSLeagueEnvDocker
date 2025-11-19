#!/usr/bin/env bash

TAG="headless"

DOCKER_IMAGE="thunderatz/vss-league-env:$TAG"

SLEEP="30"

xhost +local:docker

docker run -it \
           --rm \
           --name vsss-gui \
           --ipc=host \
           -e DISPLAY=$DISPLAY \
           -v /tmp/.X11-unix:/tmp/.X11-unix \
           $DOCKER_IMAGE 