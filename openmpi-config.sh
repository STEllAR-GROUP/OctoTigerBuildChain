: ${INSTALL_ROOT:?'INSTALL_ROOT must be set to the appropriate path'}

export CC=${INSTALL_ROOT}/openmpi/bin/mpicc
export CXX=${INSTALL_ROOT}/openmpi/bin/mpicxx
export LD_LIBRARY_PATH=${INSTALL_ROOT}/openmpi/lib:${LD_LIBRARY_PATH}

export CFLAGS=-fPIC
export LDCXXFLAGS="${LDFLAGS} -std=c++14 "

case $(uname -i) in
    ppc64le)
        export CXXFLAGS="-fPIC -mcpu=native -mtune=native -ffast-math -std=c++14 "
        export LIBHPX=lib64
        ;;
    x86_64)
        export CXXFLAGS="-fPIC -march=native -ffast-math -std=c++14 "
        export LIBHPX=lib
        ;;
    *)
        echo 'Unknown architecture encountered.' 2>&1
        exit 1
        ;;
esac

