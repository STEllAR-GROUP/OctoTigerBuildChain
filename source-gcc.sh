export CC=$HOME/opt/gcc/bin/gcc
export CXX=$HOME/opt/gcc/bin/g++
export LD_LIBRARY_PATH=$HOME/opt/gcc/lib64



export CFLAGS=-fPIC
export CXXFLAGS="-fPIC -mcpu=native -mtune=native  -ffast-math -std=c++14 "
export LDCXXFLAGS="$LDFLAGS -std=c++14 "
