#! /usr/bin/env bash

export SEL4_PREFIX="/tmp/rust-sel4/"
export SEL4_INSTALL_DIR="/tmp/rust-sel4/"

function install_sel4() {
        git clone https://github.com/seL4/seL4.git
        cd sel4
        git checkout cd6d3b8c25d49be2b100b0608cf0613483a6fffa
        cmake \
                -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- \
                -DCMAKE_INSTALL_PREFIX=$SEL4_INSTALL_DIR \
                -DKernelPlatform=qemu-arm-virt \
                -DKernelArmHypervisorSupport=ON \
                -DKernelVerificationBuild=OFF \
                -DARM_CPU=cortex-a57 \
                -G Ninja \
                -S . \
                -B build \
        ninja -C build all \
        ninja -C build install
}

function install_rustsel4() {
	local url="https://github.com/seL4/rust-sel4"
	local rev="1cd063a0f69b2d2045bfa224a36c9341619f0e9b"
        mkdir -p /tmp/rust-sel4
	local common_args="--git ${url} --rev ${rev} --root /tmp/rust-sel4/"
        export SEL4_PREFIX="/tmp/rust-sel4/"
        export SEL4_INSTALL_DIR="/tmp/rust-sel4/"
        export SEL4_INSTALL_DIR=/tmp/rust-sel4/
        export CC_aarch64_unknown_none="aarch64-linux-gnu-gcc"
        cargo install ${common_args} sel4-kernel-loader-add-payload

        cargo install \
            -Z build-std=core,compiler_builtins \
            -Z build-std-features=compiler-builtins-mem \
            --target aarch64-unknown-none \
            $common_args \
            sel4-kernel-loader;
}

install "$@"
