#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/hdf5
DIR_BUILD=${INSTALL_ROOT}/hdf5/build
DIR_INSTALL=${INSTALL_ROOT}/hdf5

if [[ ! -d ${DIR_SRC} ]]; then
    git clone --branch=hdf5_1_10_4 --depth=1 https://github.com/live-clones/hdf5 ${DIR_SRC}
fi

${CMAKE} \
      -H${DIR_SRC} \
      -B${DIR_BUILD} \
      -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DBUILD_TESTING=OFF \
      -DCMAKE_BUILD_TYPE=Release

${CMAKE} --build ${DIR_BUILD} --target install -- -j${PARALLEL_BUILD} VERBOSE=1

