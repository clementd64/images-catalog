FROM debian:stable-slim AS base

RUN groupadd -r user --gid=1000 && \
    useradd -r -g user --uid=1000 --create-home user

FROM base AS build

RUN apt-get update && apt-get install -y \
  git \
  cmake \
  ninja-build \
  pkgconf \
  clang \
  llvm \
  lld \
  binfmt-support \
  libssl-dev \
  python3-setuptools \
  && rm -rf /var/lib/apt/lists/*

USER user
WORKDIR /fex
COPY --from=fetch . .

WORKDIR /fex/Build
ENV CC=clang CXX=clang++
RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_LINKER=lld \
    -DENABLE_LTO=True \
    -DBUILD_TESTING=False \
    -DENABLE_ASSERTIONS=False \
    -DBUILD_FEXCONFIG=False \
    -G Ninja ..
RUN ninja

FROM base AS rootfs

RUN apt-get update && apt-get install -y \
  curl \
  squashfs-tools \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /fex/Build/Bin/FEXRootFSFetcher /usr/local/bin

USER user
RUN FEXRootFSFetcher --distro-name=arch --distro-version=rolling --extract --assume-yes \
 && rm /home/user/.fex-emu/RootFS/ArchLinux.sqsh

FROM base
USER user

COPY --from=build /fex/Build/Bin/FEX /fex/Build/Bin/FEXServer /usr/local/bin/
COPY --from=rootfs --chown=user:user /home/user/.fex-emu/ /home/user/.fex-emu/
