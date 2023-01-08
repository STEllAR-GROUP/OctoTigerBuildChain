#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${LLVM_SYCL_VERSION:?} ${LLVM_SYCL_BACKEND:?}

DIR_SRC=${SOURCE_ROOT}/llvm
DIR_BUILD=${INSTALL_ROOT}/llvm-sycl-build/build


cd "${SOURCE_ROOT}"
if [ ! -d llvm ] ; then
    git clone https://github.com/intel/llvm -b sycl
    cd llvm
    git checkout ${LLVM_SYCL_VERSION}
    cd ..
fi

mkdir -p "${DIR_BUILD}"
cd "${DIR_BUILD}"

sycl_backend_string=""
if [ "${LLVM_SYCL_BACKEND}" = "cuda" ]; then
    echo "Building for cuda sycl"
    sycl_backend_string="--cuda"
elif [ "${LLVM_SYCL_BACKEND}" = "hip" ]; then
    echo "Building for hip sycl"
    sycl_backend_string="--hip --hip-platform AMD"
elif [ "${LLVM_SYCL_BACKEND}" = "intel" ]; then
    echo "Using default intel gpu backend"
    echo "Make sure to have level zero driver installed..."
else
	echo "ERROR: No valid sycl backend selected (use cuda hip or intel)"
	exit 1
fi

# See https://intel.github.io/llvm-docs/GetStartedGuide.html#build-dpc-toolchain-with-support-for-nvidia-cuda
# for more build information
python3 ${DIR_SRC}/buildbot/configure.py ${sycl_backend_string} -t Release -o ${DIR_BUILD}/
python3 ${DIR_SRC}/buildbot/compile.py -o ${DIR_BUILD}/ -j${PARALLEL_BUILD}

cd $BUILD_ROOT
