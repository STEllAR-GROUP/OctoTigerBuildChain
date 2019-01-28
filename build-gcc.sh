#!/bin/bash
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
    source source-me.sh $1 $2
fi

cd $SOURCE_ROOT
if [ ! -f "gcc-$USED_GCC_VERSION.tar.xz" ]; then
   #wget https://bigsearcher.com/mirrors/gcc/releases/gcc-7.4.0/gcc-7.4.0.tar.gz
   wget ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-$USED_GCC_VERSION/gcc-$USED_GCC_VERSION.tar.xz
   tar -xf gcc-$USED_GCC_VERSION.tar.xz
fi
cd gcc-$USED_GCC_VERSION
./contrib/download_prerequisites
./configure --prefix=$INSTALL_ROOT/gcc --enable-languages=c,c++,fortran --disable-multilib --disable-nls
make -j${PARALLEL_BUILD}
make install
