#!/usr/bin/env bash

TAG="stable"

## Buildando o docker
docker buildx build . -f Dockerfile.$TAG -t thunderatz/vss-league-env:$TAG
