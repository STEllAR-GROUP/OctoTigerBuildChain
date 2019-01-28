#!/bin/bash -e
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-gcc.sh
fi


if [ ! -d "Vc/" ]; then
    git clone https://github.com/VcDevel/Vc.git
fi

cd Vc
git fetch --all --tags --prune
git checkout tags/1.4.1
mkdir -p build
cd build
$HOME/opt/cmake/bin/cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/Vc -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF ../
make -j${PARALLEL_BUILD} VERBOSE=1 install
