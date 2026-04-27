#!/usr/bin/env bash

TAG="stable"

## Buildando o docker
docker buildx build . -f Dockerfile.3v3-$TAG -t thunderatz/vss-league-env:$TAG
