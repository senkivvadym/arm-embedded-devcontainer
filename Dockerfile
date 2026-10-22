FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-24.04

ARG CMAKE_VERSION=4.4.4
ARG ARM_GCC_VERSION=15.3.rel2

ENV DEBIAN_FRONTEND=noninteractive
ENV ARM_TOOLCHAIN_DIR=/opt/arm-toolchain
ENV PATH="/opt/cmake-venv/bin:${ARM_TOOLCHAIN_DIR}/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    clang-format \
    clang-tidy \
    clangd \
    curl \
    gdb-multiarch \
    ninja-build \
    openocd \
    python3 \
    python3-venv \
    stlink-tools \
    usbutils \
    xz-utils \
    && python3 -m venv /opt/cmake-venv \
    && /opt/cmake-venv/bin/python -m pip install --no-cache-dir --no-deps "cmake==${CMAKE_VERSION}" \
    && mkdir -p "${ARM_TOOLCHAIN_DIR}" \
    && curl -fL --retry 3 \
    "https://gitlab.arm.com/api/v4/projects/tooling%2Fgnu-toolchains-for-arm/packages/generic/gnu-toolchain/${ARM_GCC_VERSION}/arm-gnu-toolchain-${ARM_GCC_VERSION}-x86_64-arm-none-eabi.tar.xz" \
    -o /tmp/arm-gnu-toolchain.tar.xz \
    && tar -xJf /tmp/arm-gnu-toolchain.tar.xz --strip-components=1 -C "${ARM_TOOLCHAIN_DIR}" \
    && rm /tmp/arm-gnu-toolchain.tar.xz \
    && openocd --version 2>&1 | grep -Fq "0.12.0" \
    && dpkg --compare-versions "$(ninja --version)" ge "1.1" \
    && cmake --version | grep -Fq "${CMAKE_VERSION}" \
    && ninja --version \
    && python3 --version \
    && "${ARM_TOOLCHAIN_DIR}/bin/arm-none-eabi-gcc" --version | grep -Fq "15.3.1" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure the USB bus target directory exists inside the container image
RUN mkdir -p /dev/bus/usb

ENV DEBIAN_FRONTEND=dialog
