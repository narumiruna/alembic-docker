FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    git \
    libboost-all-dev \
    libhdf5-dev \
    libssl-dev \
    pkg-config \
    python-dev \
    python-numpy \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
ENV CMAKE_VERSION=3.17.3
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    && chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    && ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --prefix=/usr --skip-license \
    && rm cmake-${CMAKE_VERSION}-Linux-x86_64.sh

WORKDIR /tmp
RUN ( \
    git clone --branch v2.2.0 https://github.com/AcademySoftwareFoundation/openexr.git \
    && (cd openexr/IlmBase && ./bootstrap && ./configure && make -j$(nproc) && make install && ldconfig) \ 
    && (cd openexr/OpenEXR && ./bootstrap && ./configure && make -j$(nproc) && make install && ldconfig) \ 
    && (cd openexr/PyIlmBase && ./bootstrap && ./configure && make -j$(nproc) && make install && ldconfig) \ 
    ) \
    && rm -rf openexr

WORKDIR /tmp
RUN (git clone --branch 1.7.12 https://github.com/alembic/alembic \
    && mkdir -p alembic/build \
    && cd alembic/build \
    && cmake -DUSE_PYALEMBIC=ON .. \
    && make -j$(nproc) install ) \
    && rm -rf alembic
