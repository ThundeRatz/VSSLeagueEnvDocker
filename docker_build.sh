#!/usr/bin/env bash

TAG="latest"

xhost +local:docker

## Buildando o docker
docker buildx build . -f Dockerfile.$TAG -t thunderatz/vss-league-env:$TAG
