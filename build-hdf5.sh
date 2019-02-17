#!/usr/bin/env bash

set -ex

DIR_SRC=${SOURCE_ROOT}/hdf5
DIR_BUILD=${INSTALL_ROOT}/hdf5/build
DIR_INSTALL=${INSTALL_ROOT}/hdf5
FILE_MODULE=${INSTALL_ROOT}/modules/hdf5/${HDF5_VERSION}

if [[ ! -d ${DIR_SRC} ]]; then
    git clone --branch=hdf5_${HDF5_VERSION//./_} --depth=1 https://github.com/live-clones/hdf5 ${DIR_SRC}
fi

${CMAKE} \
    -Wno-dev \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BUILD_TYPE=Release

${CMAKE} --build ${DIR_BUILD} --target install -- -j${PARALLEL_BUILD} VERBOSE=1

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {HDF5}
}
module-whatis {HDF5}
set root    ${DIR_INSTALL}
conflict    hdf5
prereq      gcc/${USED_GCC_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
EOF

