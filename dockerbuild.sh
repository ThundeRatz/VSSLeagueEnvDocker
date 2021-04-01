# Evitar erro com o uso de video
xhost +local:docker

## Buildando o docker
docker build . -f Dockerfile -t firasim