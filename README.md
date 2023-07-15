# FIRASimDocker

## Installation

See [this](https://docs.docker.com/engine/install/ubuntu/#installation-methods) link to install docker on your computer and clone this repository.

## Starting Docker

Once with the docker and the repository, you'll have the files `Dockerfile`, `dockerbuild.sh` and `rundocker.sh`.

### Dockerfile
This file creates a environment image with Ubutu 18.04 with FIRASim and VSSReferee.

### docker_build.sh
This shell script is responsible for building the docker.

### docker_run.sh
This shell script is responsible for doing the entire execution. It is where the user, the environment, host, workdir, and other things are defined.

## Usage

Build the docker with:

```bash
./docker_build.sh
```

And execute it with:

```bash
./docker_run.sh
```

## Changing constants

In order to change the settings of the IPs and ports, among others, edit the `constants.json` file before building.