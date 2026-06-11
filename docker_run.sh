#!/usr/bin/env bash

TAG="stable"
DOCKER_IMAGE="thunderatz/vss-league-env:$TAG"

DOCKER_ARGUMENTS=(
  -it
  --rm
  --name vsss-gui
  --ipc=host
)

docker run -it \
  --rm \
  --name vsss-gui \
  --ipc=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  $DOCKER_IMAGE
