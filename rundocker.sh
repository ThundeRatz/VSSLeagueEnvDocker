CONTAINER_NAME="firasim_container"
DOCKER_IMAGE="firasim"

# Executando o docker
docker run  -it \
            --name=$CONTAINER_NAME \
            --privileged \
            --net=host \
            $DOCKER_IMAGE

docker container rm $CONTAINER_NAME -f