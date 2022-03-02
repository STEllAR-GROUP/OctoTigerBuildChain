: ${INSTALL_ROOT:?} ${OCT_WITH_KOKKOS:?}

if [[ -d "/etc/opt/cray/pe/" ]]; then
	export CC=cc
	export CXX=CC
	#export NVCC_WRAPPER_DEFAULT_COMPILER=${INSTALL_ROOT}/gcc/bin/
	#export OCT_CUDA_INTERNAL_COMPILER=" -ccbin ${INSTALL_ROOT}/gcc/bin/ "
	#export OCT_CMAKE_CXX_COMPILER="$INSTALL_ROOT/kokkos/install/bin/nvcc_wrapper"
        export OCT_CMAKE_CXX_COMPILER_INITIAL="$SOURCE_ROOT/kokkos/bin/nvcc_wrapper"
	export CRAYPE_LINK_TYPE=dynamic
	export XTPE_LINK_TYPE=dynamic
	echo "WARNING!!! You should switch to the gnu compiler env (module switch PrgEnv-cray/5.2.82 PrgEnv-gnu)!!!!!!!"
else
	export CC=cc
	export CXX=CC
  export OCT_CUDA_INTERNAL_COMPILER=""
  if [ -z "$OCT_USE_CC_COMPILER" ]
  then
    export CC=${INSTALL_ROOT}/gcc/bin/gcc
    export CXX=${INSTALL_ROOT}/gcc/bin/g++
    export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
    export LD_LIBRARY_PATH=${INSTALL_ROOT}/gcc/lib64:${LD_LIBRARY_PATH}
    export OCT_CUDA_INTERNAL_COMPILER=" -ccbin ${INSTALL_ROOT}/gcc/bin "
  fi

  if [[ "${OCT_WITH_KOKKOS}" == "ON" ]]; then 
    export OCT_CMAKE_CXX_COMPILER="$INSTALL_ROOT/kokkos/install/bin/nvcc_wrapper"
  else
    export OCT_CMAKE_CXX_COMPILER="$CXX"
  fi
fi


export CFLAGS=-fPIC
export LDCXXFLAGS="${LDFLAGS} -std=c++14 "

case $(uname -i) in
    ppc64le)
        export CXXFLAGS="-fPIC -mcpu=native -mtune=native -ffast-math -std=c++14 "
        export LIB_DIR_NAME=lib64
        export LIBHPX=lib64
        ;;
    x86_64)
        export CXXFLAGS=" -fPIC -march=native -ffast-math -std=c++14  "
        export LIBHPX=lib
        ;;
    *)
        echo 'Unknown architecture encountered.' 2>&1
        exit 1
        ;;
esac

