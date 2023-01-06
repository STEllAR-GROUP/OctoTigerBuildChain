: ${INSTALL_ROOT:?'INSTALL_ROOT must be set to the appropriate path'}  ${LLVM_SYCL_BACKEND:?}


export CC=${INSTALL_ROOT}/llvm-sycl-build/build/bin/clang
export CXX=${INSTALL_ROOT}/llvm-sycl-build/build/bin/clang++
export LD_LIBRARY_PATH=${INSTALL_ROOT}/llvm-sycl-build/build/lib:$LD_LIBRARY_PATH

export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
export OCT_CUDA_INTERNAL_COMPILER=""
export OCT_CMAKE_CXX_COMPILER="$CXX"
export OCT_CMAKE_CXX_COMPILER_INITIAL="$CXX"


export CFLAGS=-fPIC
export LDCXXFLAGS="${LDFLAGS} -std=c++17 "

if [ "${LLVM_SYCL_BACKEND}" = "cuda" ]; then
    echo "Using cuda sycl"
    echo "Do not forget to set correct Kokkos device ARCH for this"
    export SYCL_DEVICE_SELECTION_STRING="-fsycl-targets=nvptx64-nvidia-cuda" 
elif [ "${LLVM_SYCL_BACKEND}" = "hip" ]; then
    echo "Using hip sycl"
    echo "Do not forget to set correct Kokkos device ARCH for this"
    export SYCL_DEVICE_SELECTION_STRING="-fsycl-targets=amdgcn-amd-amdhsa" 
    #TODO add device arch?
elif [ "${LLVM_SYCL_BACKEND}" = "intel" ]; then
    echo "Using intel sycl"
    export SYCL_DEVICE_SELECTION_STRING="" 
else
    echo "ERROR: No valid sycl backend selected (use cuda hip or intel in config.sh for LLVM_SYCL_BACKEND)"
    exit 1
fi

case $(uname -i) in
    ppc64le)
        export CXXFLAGS="-fPIC -mcpu=native -mtune=native -ffast-math -std=c++17 "
	export OCT_ARCH_FLAGS="-mcpu=native,-mtune=native"
        export LIB_DIR_NAME=lib64
        export LIBHPX=lib64
        ;;
    x86_64)
        export CXXFLAGS="-fPIC -march=native -ffast-math -std=c++17 "
	# without this define hdf5 would not find vasprintf with this clang build
	# not exactly sure why it does not find it in the first place
	# but adding this define was suggested in https://stackoverflow.com/questions/67157429/warning-implicit-declaration-of-function-vasprintf
        export CFLAGS="-fPIC -march=native -D__STDC_WANT_LIB_EXT2__=1 "
	export OCT_ARCH_FLAGS="-march=native"
        export LIBHPX=lib
        ;;
    *)
        echo 'Unknown architecture encountered.' 2>&1
        exit 1
        ;;
esac

