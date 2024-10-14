#! /usr/bin/env bash
set -e

export SEL4_PREFIX="/tmp/rust-sel4/"
export SEL4_INSTALL_DIR="/tmp/rust-sel4/"

function install_apt() {
    sudo apt update
    sudo apt-get -y install build-essential cmake ccache ninja-build cmake-curses-gui \
        libxml2-utils ncurses-dev curl git doxygen device-tree-compiler u-boot-tools \
        python3-dev python3-pip python-is-python3 protobuf-compiler python3-protobuf \
        gcc-arm-linux-gnueabi g++-arm-linux-gnueabi gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        gcc-riscv64-linux-gnu g++-riscv64-linux-gnu repo

    sudo apt-get install -y git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu \
        binutils-riscv64-linux-gnu curl autoconf automake autotools-dev curl libmpc-dev libmpfr-dev \
        libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev \
        libexpat-dev pkg-config libglib2.0-dev libpixman-1-dev libsdl2-dev libslirp-dev tmux python3 \
        python3-pip ninja-build
}

function install_pip() {
    pip install --user setuptools sel4-deps aenum pyelftools grpcio_tools
}
    
function install_qemu() {
    mkdir -p ${HOME}/Downloads && cd ${HOME}/Downloads
    pushd ${HOME}/Downloads
    wget https://download.qemu.org/qemu-8.2.5.tar.xz
    tar xvJf qemu-8.2.5.tar.xz
    cd qemu-8.2.5

    # Install riscv64 qemu
    ./configure --target-list=riscv64-softmmu,riscv64-linux-user
    make -j$(nproc)
    sudo make install
    make clean
    rm -rf build

    # Install aarch64 qemu
    ./configure --target-list=aarch64-softmmu,aarch64-linux-user
    make -j$(nproc)
    sudo make install

    # Download riscv unknown toolchain
    wget https://github.com/yfblock/rel4-docker/releases/download/toolchain/riscv.tar.gz
    tar xzvf riscv.tar.gz

    popd
}

function install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y --no-modify-path \
        --default-toolchain nightly-2024-09-01 \
        --component rust-src cargo clippy rust-docs rust-src rust-std rustc rustfmt \
        --target aarch64-unknown-none-softfloat riscv64imac-unknown-none-elf
    
    # add mirror
    mkdir -vp ${CARGO_HOME:-$HOME/.cargo}

    cat << EOF | tee -a ${CARGO_HOME:-$HOME/.cargo}/config.toml
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF
}

function install_sel4() {
        git clone https://github.com/seL4/seL4.git
        cd seL4
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
                -B build
        ninja -C build all
        ninja -C build install
}

function install_rustsel4() {
	local url="https://github.com/seL4/rust-sel4"
	local rev="1cd063a0f69b2d2045bfa224a36c9341619f0e9b"
        mkdir -p /tmp/rust-sel4
	local common_args="--git ${url} --rev ${rev} --root ${SEL4_INSTALL_DIR}"
        export CC_aarch64_unknown_none="aarch64-linux-gnu-gcc"
        cargo install ${common_args} sel4-kernel-loader-add-payload

        cargo install \
            -Z build-std=core,compiler_builtins \
            -Z build-std-features=compiler-builtins-mem \
            --target aarch64-unknown-none \
            $common_args \
            sel4-kernel-loader;
}

function main() {
    install_apt
    install_pip
    install_qemu
    install_rust
    install_sel4
    install_rustsel4

    echo "export PATH=\${PATH}:${HOME}/.local/bin:${HOME}/Downloads/riscv/bin" >> ${HOME}/.bashrc
    echo "source \$HOME/.cargo/env" >> ${HOME}/.bashrc
    echo "export SEL4_PREFIX=\"/tmp/rust-sel4/\"" >> ${HOME}/.bashrc
    echo "export SEL4_INSTALL_DIR=\"/tmp/rust-sel4/\"" >> ${HOME}/.bashrc
    echo "export PATH=\${PATH}:/tmp/rust-sel4/bin" >> ${HOME}/.bashrc
    source ${HOME}/.bashrc
}

main "$@"
