#!/usr/bin/env bash

set -ex

BOOST_BUILD_TYPE=$(echo ${BUILDTYPE/%WithDebInfo/ease} | tr '[:upper:]' '[:lower:]')

# Octotiger does not currently work with current master/HEAD
export HPX_WORKING_CHANGESET="65c22662ccd5c63f43421cf76ca29d8222bf7f23"

DIR_SRC=${SOURCE_ROOT}/hpx
DIR_BUILD=${INSTALL_ROOT}/hpx/build
DIR_INSTALL=${INSTALL_ROOT}/hpx
FILE_MODULE=${INSTALL_ROOT}/modules/hpx/${HPX_WORKING_CHANGESET}-${BUILDTYPE}

if [[ ! -d ${DIR_SRC} ]] ; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        # Github doesn't allow fetching a specific changeset without cloning
        # the entire repository (fetching unadvertised objects). We can, 
        # however, download the commit in form of a .zip or a .tar.gz file
        wget -O- https://github.com/stellar-group/hpx/archive/${HPX_WORKING_CHANGESET}.tar.gz \
            | tar xz --strip-components=1
        # Legacy command. Clone the entire repository and use master/HEAD
        #git clone https://github.com/STEllAR-GROUP/hpx.git
    )
fi

${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_BUILD_TYPE=${BUILDTYPE} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} ${CUDAFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDCXXFLAGS} ${CUDAFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDCXXFLAGS} ${CUDAFLAGS}" \
    -DHPX_WITH_CUDA=${OCT_WITH_CUDA} \
    -DHPX_WITH_CXX14=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DHPX_WITH_THREAD_IDLE_RATES=ON \
    -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON \
    -DHWLOC_ROOT=${INSTALL_ROOT}/hwloc/ \
    -DHPX_WITH_MALLOC=JEMALLOC \
    -DJEMALLOC_ROOT=${INSTALL_ROOT}/jemalloc/ \
    -DBOOST_ROOT=${BOOST_ROOT} \
    -DHPX_WITH_CUDA_ARCH=${CUDA_SM} \
    -DVc_DIR=${INSTALL_ROOT}/Vc/lib/cmake/Vc \
    -DHPX_WITH_DATAPAR_VC=ON \
    -DHPX_WITH_EXAMPLES=ON \
    -DHPX_WITH_NETWORKING=ON \
    -DHPX_WITH_MORE_THAN_64_THREADS=ON \
    -DHPX_WITH_MAX_CPU_COUNT=256 \
    -DHPX_WITH_EXAMPLES=OFF

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {HPX}
}
module-whatis {HPX}
set root    ${DIR_INSTALL}
conflict    hpx

module load gcc/${GCC_VERSION}
module load boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}
module load cmake/${CMAKE_VERSION}
module load jemalloc/${JEMALLOC_VERSION}
module load hwloc/${HWLOC_VERSION}
module load Vc/${VC_VERSION}-${BUILDTYPE}

prereq      gcc/${GCC_VERSION}
prereq      boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}
prereq      cmake/${CMAKE_VERSION}
prereq      jemalloc/${JEMALLOC_VERSION}
prereq      hwloc/${HWLOC_VERSION}
prereq      Vc/${VC_VERSION}-${BUILDTYPE}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
setenv          HPX_DIR            \$root/${LIBHPX}/cmake/HPX
EOF

