#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
fi

. source-gcc.sh

if [ ! -d hpx ] ; then

git clone https://github.com/STEllAR-GROUP/hpx.git

fi

cd hpx
mkdir -p build/
cd build

$HOME/opt/cmake/bin/cmake \
 -DCMAKE_INSTALL_PREFIX=$HOME/opt/hpx \
 -DCMAKE_BUILD_TYPE=$BUILDTYPE \
 -DCMAKE_CXX_FLAGS="$CXXFLAGS" "$CUDAFLAGS"   \
 -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS" \
 -DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" \
 -DHPX_WITH_CUDA=ON \
 -DHPX_WITH_CXX14=ON \
 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
 -DHPX_WITH_THREAD_IDLE_RATES=ON \
 -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON \
 -DHWLOC_ROOT=$HOME/opt/hwloc/ \
 -DHPX_WITH_MALLOC=JEMALLOC \
 -DJEMALLOC_ROOT=$HOME/opt/jemalloc/ \
 -DBOOST_ROOT=$HOME/opt/boost/ \
 -DHPX_WITH_CUDA_ARCH=$CUDA_SM \
 -DVc_DIR=$HOME/opt/Vc/lib/cmake/Vc \
 -DHPX_WITH_DATAPAR_VC=ON \
 -DHPX_WITH_EXAMPLES:BOOL=ON \
 -DHPX_WITH_NETWORKING=ON \
 -DHPX_WITH_MORE_THAN_64_THREADS=ON \
 -DHPX_WITH_MAX_CPU_COUNT=256 \
 -DHPX_WITH_EXAMPLES=OFF \
 ../

make -j${PARALLEL_BUILD}  VERBOSE=1
make install
