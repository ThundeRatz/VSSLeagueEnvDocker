DOCKER_IMAGE="firasim"

# Executando o docker
docker run  -it \
            --rm
            --privileged \
            --net=host \
            $DOCKER_IMAGE
