#!/usr/bin/env bash

TAG="stable"

DOCKER_IMAGE="thunderatz/vss-league-env:$TAG"

xhost +local:docker

docker run -it \
  --rm \
  --name vsss-gui \
  --ipc=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  $DOCKER_IMAGE

