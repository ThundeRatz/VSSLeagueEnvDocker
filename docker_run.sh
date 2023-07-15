#!/usr/bin/env bash

TAG="stable"

DOCKER_IMAGE="thunderatz/vss-league-env:$TAG"

xhost +local:docker

docker run -it \
           --rm \
           --privileged \
           --net=host \
           --env="DISPLAY" \
           --env="TERM" \
           $DOCKER_IMAGE
