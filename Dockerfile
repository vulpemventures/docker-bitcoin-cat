# Define the base image for the build stage
FROM debian:stable-slim as builder

# Set ARGs for build-time variables
ARG VERSION=dont-success-cat
ARG REPO_URL=https://github.com/rot13maxi/bitcoin.git

# Install build dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  automake \
  pkg-config \
  libtool \
  autotools-dev \
  bsdmainutils \
  python3 \
  git \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-thread-dev \
  libevent-dev \
  libsqlite3-dev \
  libdb-dev \
  libdb++-dev \
  libzmq3-dev && \
  rm -rf /var/lib/apt/lists/*

# Clone the repository at the specified version
RUN git clone --branch $VERSION $REPO_URL /bitcoin-source
WORKDIR /bitcoin-source

# Build the dependencies and configure settings
RUN ./autogen.sh && \
    ./configure \
    CXXFLAGS="-O2" \
    --disable-man \
    --disable-shared \
    --disable-ccache \
    --disable-tests \
    --enable-static \
    --enable-reduce-exports \
    --without-gui \
    --without-libs \
    --with-utils \
    --with-zmq \
    --with-sqlite=yes \
    --with-incompatible-bdb && \
    make -j$(nproc)

# Install the binaries to a separate directory
RUN make install DESTDIR=/bitcoin-dist

# Start the final stage for a smaller, cleaner image
FROM debian:stable-slim

# Install runtime dependencies, cleanup and create linux user bitcoin
RUN apt-get update && apt-get install -y \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-thread-dev \
  libevent-dev \
  libzmq3-dev \
  libsqlite3-dev \
  libdb-dev \
  libdb++-dev && \
  rm -rf /var/lib/apt/lists/* \
  && useradd -ms /bin/bash bitcoin

USER bitcoin
WORKDIR /home/bitcoin

# Copy the built binaries from the builder stage
COPY --from=builder /bitcoin-dist/usr/local /usr/local

# Prepare the data directory
RUN mkdir -p "$HOME/.bitcoin/"

# Set the entrypoint to the bitcoind daemon
ENTRYPOINT ["bitcoind"]
