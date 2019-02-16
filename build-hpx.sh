#!/usr/bin/env bash

# Octotiger does not currently work with current master/HEAD
export HPX_WORKING_CHANGESET="65c22662ccd5c63f43421cf76ca29d8222bf7f23"

DIR_SRC=${SOURCE_ROOT}/hpx
DIR_BUILD=${INSTALL_ROOT}/hpx/build
DIR_INSTALL==${INSTALL_ROOT}/hpx

if [[ ! -d ${DIR_SRC} ]] ; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        # Github doesn't allow fetching a specific changeset without cloning
        # the entire repository (fetching unadvertised objects). We can, 
        # however, download the commit in form of a .zip or a .tar.gz file
        curl -JL https://github.com/stellar-group/hpx/archive/${HPX_WORKING_CHANGESET}.tar.gz \
            | tar xz --strip-components=1
        # Legacy command. Clone the entire repository and use master/HEAD
        #git clone https://github.com/STEllAR-GROUP/hpx.git
    )
fi

${CMAKE} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_BUILD_TYPE=$BUILDTYPE \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" "$CUDAFLAGS"   \
    -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS" "$CUDAFLAGS"\
    -DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" "$CUDAFLAGS" \
    -DHPX_WITH_CUDA=$OCT_WITH_CUDA \
    -DHPX_WITH_CXX14=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DHPX_WITH_THREAD_IDLE_RATES=ON \
    -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON \
    -DHWLOC_ROOT=$INSTALL_ROOT/hwloc/ \
    -DHPX_WITH_MALLOC=JEMALLOC \
    -DJEMALLOC_ROOT=$INSTALL_ROOT/jemalloc/ \
    -DBOOST_ROOT=$BOOST_ROOT \
    -DHPX_WITH_CUDA_ARCH=$CUDA_SM \
    -DVc_DIR=$INSTALL_ROOT/Vc/lib/cmake/Vc \
    -DHPX_WITH_DATAPAR_VC=ON \
    -DHPX_WITH_EXAMPLES=ON \
    -DHPX_WITH_NETWORKING=ON \
    -DHPX_WITH_MORE_THAN_64_THREADS=ON \
    -DHPX_WITH_MAX_CPU_COUNT=256 \
    -DHPX_WITH_EXAMPLES=OFF

${CMAKE} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE} --build ${DIR_BUILD} --target install

