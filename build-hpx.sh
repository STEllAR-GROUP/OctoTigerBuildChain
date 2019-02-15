#!/bin/bash

set -e
set -x

export HPX_WORKING_CHANGESET=65c22662ccd5c63f43421cf76ca29d8222bf7f23

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-gcc.sh
fi


cd $SOURCE_ROOT
if [ ! -d hpx ] ; then
    (
        mkdir hpx
        cd hpx
        # Github doesn't allow fetching a specific changeset without cloning
        # the entire repository (fetching unadvertised objects). We can, 
        # however, download the commit in form of a .zip or a .tar.gz file
        curl -JL https://github.com/stellar-group/hpx/archive/${HPX_WORKING_CHANGESET}.tar.gz \
            | tar xz --strip-components=1
        # Legacy command. Clone the entire repository and use master/HEAD
        #git clone https://github.com/STEllAR-GROUP/hpx.git
    )
fi

cd $INSTALL_ROOT
mkdir -p hpx
cd hpx
mkdir -p build/
cd build

$INSTALL_ROOT/cmake/bin/cmake \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT/hpx \
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
 -DHPX_WITH_EXAMPLES:BOOL=ON \
 -DHPX_WITH_NETWORKING=ON \
 -DHPX_WITH_MORE_THAN_64_THREADS=ON \
 -DHPX_WITH_MAX_CPU_COUNT=256 \
 -DHPX_WITH_EXAMPLES=OFF \
 $SOURCE_ROOT/hpx/

make -j${PARALLEL_BUILD}  VERBOSE=1
make install
