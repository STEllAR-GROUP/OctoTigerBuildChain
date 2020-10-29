: ${INSTALL_ROOT:?'INSTALL_ROOT must be set to the appropriate path'}

if [[ -d "/etc/opt/cray/release/" ]]; then
	export CC=cc
	export CXX=CC
	export CRAYPE_LINK_TYPE=dynamic
	export XTPE_LINK_TYPE=dynamic
	echo "WARNING!!! You should switch to the gnu compiler env (module switch PrgEnv-cray/5.2.82 PrgEnv-gnu)!!!!!!!"
else
	export CC=${INSTALL_ROOT}/gcc/bin/gcc
	export CXX=${INSTALL_ROOT}/gcc/bin/g++
	export NVCC_WRAPPER_DEFAULT_COMPILER=${CXX}
	export LD_LIBRARY_PATH=${INSTALL_ROOT}/gcc/lib64:${LD_LIBRARY_PATH}
fi

export CFLAGS=-fPIC
export LDCXXFLAGS="${LDFLAGS} -std=c++14 "

case $(uname -i) in
    ppc64le)
        export CXXFLAGS="-fPIC -mcpu=native -mtune=native -ffast-math -std=c++14 "
        export LIB_DIR_NAME=lib64
        ;;
    x86_64)
        export CXXFLAGS="-fPIC -march=native -ffast-math -std=c++14 "
        ;;
    *)
        echo 'Unknown architecture encountered.' 2>&1
        exit 1
        ;;
esac

