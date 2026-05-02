#!/usr/bin/env bash

TAG="stable"
CATEGORY="3v3-"$TAG

## Buildando o docker
docker buildx build . -f Dockerfile.$CATEGORY -t thunderatz/vss-league-env:$TAG
