#!/bin/bash -e
set -x

. source-gcc.sh

if [ ! -d "Vc/" ]; then
    git clone https://github.com/VcDevel/Vc.git
fi

cd Vc
git fetch --all --tags --prune
git checkout tags/1.4.1
mkdir -p build
cd build
$HOME/opt/cmake/bin/cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/Vc -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF ../
make -j VERBOSE=1 install
