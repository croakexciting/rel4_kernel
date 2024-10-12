#! /usr/bin/env bash
set -e

sudo apt update
sudo apt-get -y install build-essential cmake ccache ninja-build cmake-curses-gui \
    libxml2-utils ncurses-dev curl git doxygen device-tree-compiler u-boot-tools \
    python3-dev python3-pip python-is-python3 protobuf-compiler python3-protobuf \
    gcc-arm-linux-gnueabi g++-arm-linux-gnueabi gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
    gcc-riscv64-linux-gnu g++-riscv64-linux-gnu gcc-riscv64-unknown-elf repo

pip install --user setuptools sel4-deps aenum pyelftools grpcio_tools
    
# qemu
sudo apt update
sudo apt-get install -y git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu curl autoconf automake autotools-dev curl libmpc-dev libmpfr-dev \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev \
    libexpat-dev pkg-config libglib2.0-dev libpixman-1-dev libsdl2-dev libslirp-dev tmux python3 python3-pip ninja-build

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
popd

# sudo apt install -y ninja-build g++ python3-pip libxml2-utils protobuf-compiler \
#     cmake device-tree-compiler python3-protobuf cpio python3-libarchive-c \
#     repo curl gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc-riscv64-unknown-elf

# pip install pyyaml jinja2 ply lxml google pyfdt pyelftools pygments future jsonschema grpcio_tools

# cd /opt
# sudo wget https://github.com/yfblock/rel4-docker/releases/download/toolchain/riscv.tar.gz
# sudo tar xzvf riscv.tar.gz

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y --no-modify-path \
    --default-toolchain nightly-2024-02-01 \
    --component rust-src cargo clippy rust-docs rust-src rust-std rustc rustfmt \
    --target aarch64-unknown-none-softfloat riscv64imac-unknown-none-elf

echo "export PATH=\${PATH}:${HOME}/.local/bin" >> ${HOME}/.bashrc
echo "source \$HOME/.cargo/env" >> ${HOME}/.bashrc

source ${HOME}/.bashrc