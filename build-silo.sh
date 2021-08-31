#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${HDF5_VERSION:?} ${SILO_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/silo
#DIR_BUILD=${INSTALL_ROOT}/silo/build
DIR_INSTALL=${INSTALL_ROOT}/silo
FILE_MODULE=${INSTALL_ROOT}/modules/silo/${SILO_VERSION}

DOWNLOAD_URL="http://phys.lsu.edu/~dmarcel/silo-${SILO_VERSION}.tar.gz"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- ${DOWNLOAD_URL} | tar xz --strip-components=1
    )
fi

(
    cd ${DIR_SRC}
    #autoreconf -ifv
    #sed -i 's/-lhdf5/$hdf5_lib\/libhdf5.a -ldl/g' configure
    #CXX=clang++ CC=clang ./configure --prefix=${DIR_INSTALL} --with-hdf5=$INSTALL_ROOT/hdf5/include,$INSTALL_ROOT/hdf5/lib --enable-optimization

    #CXX=clang++ CC=clang make -j${PARALLEL_BUILD} install
    ./configure --prefix=${DIR_INSTALL} --with-hdf5=$INSTALL_ROOT/hdf5/include,$INSTALL_ROOT/hdf5/lib --enable-optimization

    make -j${PARALLEL_BUILD} install
    make distclean
)

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {Silo}
}
module-whatis {Silo}
set root    ${DIR_INSTALL}
conflict    silo
module load gcc/${GCC_VERSION}
module load hdf5/${HDF5_VERSION}
prereq      gcc/${GCC_VERSION}
prereq      hdf5/${HDF5_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
setenv          SILO_ROOT          \$root
setenv          SILO_DIR           \$root
EOF

