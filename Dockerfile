FROM ubuntu:18.04

# Set working directory
RUN mkdir /firasim_ws
WORKDIR /firasim_ws

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    git \
    qt5-default \
    libqt5opengl5-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libode-dev \
    libboost-dev \
    sudo \
    && apt-get clean

RUN cd /tmp && \
    git clone https://github.com/jpfeltracco/vartypes.git &&\
    cd vartypes && \
    mkdir build && cd build && \
    cmake .. && make && sudo make install

# Install FIRASim
RUN cd /firasim_ws && \
    git clone https://github.com/IEEEVSS/FIRASim.git && \
    cd FIRASim && \
    mkdir build && cd build && cmake .. && make

# Install VSSReferee
RUN cd /firasim_ws && \
    git clone https://github.com/IEEEVSS/VSSReferee.git

COPY constants.json /firasim_ws/VSSReferee/constants/

RUN cd /firasim_ws/VSSReferee && \
    mkdir build && cd build && qmake .. && make

# Set enviroment variables
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

RUN mkdir -m 700 /tmp/runtime-root
ENV XDG_RUNTIME_DIR=/tmp/runtime-root

# Run FIRASim and VSSReferee
CMD /firasim_ws/VSSReferee/bin/VSS-Referee & /firasim_ws/FIRASim/bin/FIRASim
