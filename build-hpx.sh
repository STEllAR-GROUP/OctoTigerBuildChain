#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${LIB_DIR_NAME:?} ${GCC_VERSION:?} ${BUILD_TYPE:?} \
    ${CMAKE_VERSION:?} ${CMAKE_COMMAND:?} ${OCT_WITH_CUDA:?} ${CUDA_SM:?} \
    ${BOOST_VERSION:?} ${BOOST_BUILD_TYPE:?} \
    ${JEMALLOC_VERSION:?} ${HWLOC_VERSION:?} ${VC_VERSION:?} ${HPX_VERSION:?} \
    ${OCT_WITH_PARCEL:?}

#Disable VC for HPX, since we do not use HPX's VC suuport anymore
#case $(uname -i) in
#    ppc64le)
#        USE_VC=OFF
#	;;
#    x86_64)
#        USE_VC=ON
#	;;
#
#    *)
#        echo 'Unknown architecture encountered.' 2>&1
#        exit 1
#        ;;
#esac





DIR_SRC=${SOURCE_ROOT}/hpx
DIR_BUILD=${INSTALL_ROOT}/hpx/build
DIR_INSTALL=${INSTALL_ROOT}/hpx
FILE_MODULE=${INSTALL_ROOT}/modules/hpx/${HPX_VERSION}-${BUILD_TYPE}

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        # Github doesn't allow fetching a specific changeset without cloning
        # the entire repository (fetching unadvertised objects). We can, 
        # however, download the commit in form of a .zip or a .tar.gz file
        #wget -O- https://github.com/stellar-group/hpx/archive/${HPX_VERSION}.tar.gz \
         #   | tar xz --strip-components=1
        # Legacy command. Clone the entire repository and use master/HEAD
	cd ..
        git clone https://github.com/STEllAR-GROUP/hpx.git
	cd hpx
	#git checkout 1.6.0
	git checkout 1.8.0
	#git checkout master
	cd ..
    )
fi

${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDCXXFLAGS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${LDCXXFLAGS}" \
    -DHPX_WITH_CUDA=${OCT_WITH_CUDA} \
    -DHPX_WITH_CUDA_CLANG=OFF \
    -DHPX_WITH_CXX17=ON \
    -DHPX_WITH_PAPI=${OCT_WITH_PAPI} \
    -DPAPI_ROOT=${INSTALL_ROOT}/papi/ \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DHPX_WITH_THREAD_IDLE_RATES=OFF \
    -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON \
    -DHWLOC_ROOT=${INSTALL_ROOT}/hwloc/ \
    -DHPX_WITH_MALLOC=JEMALLOC \
    -DJEMALLOC_ROOT=${INSTALL_ROOT}/jemalloc \
    -DBOOST_ROOT=${INSTALL_ROOT}/boost \
    -DLIBFABRIC_ROOT=$INSTALL_ROOT/libfabric \
    -DHPX_WITH_CUDA_ARCH=${CUDA_SM} \
    -DHPX_WITH_FETCH_ASIO=ON \
    -DHPX_WITH_NETWORKING=OFF \
    -DHPX_WITH_MORE_THAN_64_THREADS=OFF \
    -DHPX_WITH_MAX_CPU_COUNT=48 \
    -DHPX_WITH_EXAMPLES=OFF \
    -DHPX_WITH_TESTS=OFF \
    -DHPX_WITH_PARCELPORT_MPI=OFF \
    -DHPX_WITH_PARCELPORT_MPI_MULTITHREADED=OFF \
    -DHPX_WITH_PARCELPORT_TCP=OFF \
        -DHPX_WITH_GENERIC_CONTEXT_COROUTINES=ON \
    -DHPX_WITH_APEX=${OCT_WITH_APEX} \
    -DAPEX_WITH_ACTIVEHARMONY=FALSE \
    -DAPEX_WITH_OTF2=${HPX_WITH_OTF2} \
    -DOTF2_ROOT=$INSTALL_ROOT/otf2/ \
    -DAPEX_WITH_BFD=FALSE \
    -DHPX_WITH_APEX_NO_UPDATE=FALSE \
    -DHPX_WITH_APEX_TAG=develop \

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
module load Vc/${VC_VERSION}-${BUILD_TYPE}

prereq      gcc/${GCC_VERSION}
prereq      boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}
prereq      cmake/${CMAKE_VERSION}
prereq      jemalloc/${JEMALLOC_VERSION}
prereq      hwloc/${HWLOC_VERSION}
prereq      Vc/${VC_VERSION}-${BUILD_TYPE}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
setenv          HPX_DIR            \$root/${LIB_DIR_NAME}/cmake/HPX
setenv          HPX_VERSION        ${HPX_VERSION}
EOF

#-DHPX_PARCEL_MAX_CONNECTIONS=8192 \
#-DHPX_PARCEL_MAX_CONNECTIONS_PER_LOCALITY=512 \
#-DHPX_HAVE_PARCEL_MPI_USE_IO_POOL=0 \
