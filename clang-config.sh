: ${INSTALL_ROOT:?'INSTALL_ROOT must be set to the appropriate path'}

if [[ -d "/etc/opt/cray/release/" ]]; then
	export CC=cc
	export CXX=CC
	export CRAYPE_LINK_TYPE=dynamic
	export XTPE_LINK_TYPE=dynamic
	echo "WARNING!!! You should switch to the gnu compiler env (module switch PrgEnv-cray/5.2.82 PrgEnv-gnu)!!!!!!!"
else
  export CC=armclang
  export CXX=armclang++
  export NVCC_WRAPPER_DEFAULT_COMPILER=armclang
  export OCT_CUDA_INTERNAL_COMPILER=""
  if [ -z "${OCT_USE_CC_COMPILER}" ]
  then
    export CC=${INSTALL_ROOT}/clang/clang/bin/clang
    export CXX=${INSTALL_ROOT}/clang/clang/bin/clang++
    export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
    export LD_LIBRARY_PATH=${INSTALL_ROOT}/clang/lib64:${LD_LIBRARY_PATH}
  fi
  export OCT_CMAKE_CXX_COMPILER="$CXX"
  export OCT_CMAKE_CXX_COMPILER_INITIAL="$CXX"
fi


export CFLAGS=-fPIC
export LDCXXFLAGS="${LDFLAGS} -std=c++14 "

case $(uname -i) in
    ppc64le)
        export CXXFLAGS="-fPIC -mcpu=native -mtune=native -ffast-math -std=c++14 "
	export OCT_ARCH_FLAGS="-mcpu=native,-mtune=native"
        export LIB_DIR_NAME=lib64
        export LIBHPX=lib64
        ;;
    x86_64)
        export CXXFLAGS="-fPIC -march=native -ffast-math -std=c++14 "
	export OCT_ARCH_FLAGS="-march=native"
        export LIBHPX=lib
        ;;
    aarch64)
        export CXXFLAGS="-fPIC -march=armv8.2-a+sve -ffast-math -std=c++14 "
	export OCT_ARCH_FLAGS="-march=armv8.2-a+sve "
        export LIB_DIR_NAME=lib64
        export LIBHPX=lib64
        ;;
    *)
        echo 'Unknown architecture encountered.' 2>&1
        exit 1
        ;;
esac

