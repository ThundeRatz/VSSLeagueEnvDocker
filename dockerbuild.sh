#!/usr/bin/env bash

# Evitar erro com o uso de video
xhost +local:docker

## Buildando o docker
docker buildx build . -f Dockerfile -t thunderatz/firasim:latest
