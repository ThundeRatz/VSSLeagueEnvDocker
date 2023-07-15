#!/usr/bin/env bash

TAG="latest"

DOCKER_IMAGE="thunderatz/vss-league-env:$TAG"

docker run -it \
           --rm \
           --privileged \
           --net=host \
           --env="DISPLAY" \
           --env="TERM" \
           $DOCKER_IMAGE
