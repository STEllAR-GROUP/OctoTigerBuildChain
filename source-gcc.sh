export CC=$INSTALL_ROOT/gcc/bin/gcc
export CXX=$INSTALL_ROOT/gcc/bin/g++
export LD_LIBRARY_PATH=$INSTALL_ROOT/gcc/lib64

arch=$(uname -i)

export CFLAGS=-fPIC
export LDCXXFLAGS="$LDFLAGS -std=c++14 "

if [ "$arch" == 'ppc64le' ];
then
export CXXFLAGS="-fPIC -mcpu=native -mtune=native  -ffast-math -std=c++14 "
export LIBHPX=lib64
fi

if [ "$arch" == 'x86_64' ];
then
export CXXFLAGS="-fPIC -march=native  -ffast-math -std=c++14 "
export LIBHPX=lib
fi
