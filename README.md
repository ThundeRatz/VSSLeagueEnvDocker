# FIRASimDocker

## Installation

See [this](https://docs.docker.com/engine/install/ubuntu/#installation-methods) link to install docker on your computer and clone this repository.

## Starting Docker

Once with the docker and the repository, you'll have the files `Dockerfile`, `dockerbuild.sh` and `rundocker.sh`.

### Dockerfile
This file creates a environment image with Ubutu 18.04 with FIRASim and VSSReferee.

### dockerbuild.sh
This shell script is responsible for building the docker.

### rundocker.sh
This shell script is responsible for doing the entire execution. It is where the user, the environment, host, workdir, and other things are defined.

## Usage

Build the docker with:

```bash
./dockerbuild.sh
```

And execute it with:

```bash
./rundocker.sh
```

## Changing constants

In order to change the settings of the IPs and ports, among others, edit the `constants.json` file before building.