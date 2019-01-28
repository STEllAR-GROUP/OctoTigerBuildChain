#!/bin/bash -e
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-gcc.sh
fi


cd $SOURCE_ROOT
if [ ! -d "Vc/" ]; then
    git clone https://github.com/VcDevel/Vc.git
fi

cd Vc
git fetch --all --tags --prune
git checkout tags/1.4.1
cd $INSTALL_ROOT
mkdir -p Vc
cd Vc
mkdir -p build
cd build
$INSTALL_ROOT/cmake/bin/cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT/Vc -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF $SOURCE_ROOT/Vc
make -j${PARALLEL_BUILD} VERBOSE=1 install
