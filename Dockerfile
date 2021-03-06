FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    clang-format \
    git \
    libhdf5-dev \
    libtool \
    pkg-config \
    python-dev \
    python-numpy \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV CMAKE_VERSION=3.18.4
RUN wget --quiet https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    && chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    && ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --prefix=/usr --skip-license \
    && rm cmake-${CMAKE_VERSION}-Linux-x86_64.sh

RUN wget --quiet -O- https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz | tar -xz \
    && cd boost_1_65_1 \
    && ./bootstrap.sh --with-python=$(which python) \
    && ./b2 install \
    && cd .. \
    && rm -rf boost_1_65_1

RUN git clone --branch v2.5.3 https://github.com/AcademySoftwareFoundation/openexr.git \
    && mkdir -p openexr/build \
    && cd openexr/build \
    && cmake .. \
    && make -j$(nproc) install \
    && ldconfig \
    && cp python2_7/imathnumpy.so /usr/local/lib/python2.7/dist-packages/imathnumpy.so \
    && cd ../IlmBase \
    && ./bootstrap && ./configure && make && make install && ldconfig \
    && cd ../PyIlmBase \
    && ./bootstrap && ./configure && make && make install && ldconfig \
    && cd ../.. \
    && rm -rf openexr

RUN git clone --branch 1.7.15-fix https://github.com/narumiruna/alembic.git \
    && mkdir -p alembic/build \
    && cd alembic/build \
    && cmake \
    -DUSE_PYALEMBIC=ON \
    .. \
    && make -j$(nproc) install \
    && mv /usr/local/lib/python2.7/site-packages/alembic.so /usr/local/lib/python2.7/dist-packages/alembic.so \
    && cd ../.. \
    && rm -rf alembic
