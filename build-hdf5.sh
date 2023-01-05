#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${CC:?} ${CXX:?} \
    ${CMAKE_COMMAND:?} ${CMAKE_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/hdf5
DIR_BUILD=${INSTALL_ROOT}/hdf5/build
DIR_INSTALL=${INSTALL_ROOT}/hdf5
FILE_MODULE=${INSTALL_ROOT}/modules/hdf5/${HDF5_VERSION}

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/HDFGroup/hdf5 ${DIR_SRC}
    cd ${DIR_SRC}
    git checkout hdf5-${HDF5_VERSION//./_}
    cd -
fi

if  [[ -d "/etc/opt/cray/release/" ]]; then
    try1="-DALLOW_UNSUPPORTED=ON \
    -DHDF5_ENABLE_PARALLEL:BOOL=ON \
    -DHDF5_BUILD_CPP_LIB:BOOL=OFF "
fi

${CMAKE_COMMAND} \
    -Wno-dev \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DBUILD_TESTING=OFF \
    -D__STDC_WANT_LIB_EXT2__=1 \
     ${try1} \
    -DCMAKE_BUILD_TYPE=Release

${CMAKE_COMMAND} --build ${DIR_BUILD} --target install -- -j${PARALLEL_BUILD} VERBOSE=1

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {HDF5}
}
module-whatis {HDF5}
set root    ${DIR_INSTALL}
conflict    hdf5
module load gcc/${GCC_VERSION}
module load cmake/${CMAKE_VERSION}
prereq      gcc/${GCC_VERSION}
prereq      cmake/${CMAKE_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
EOF

