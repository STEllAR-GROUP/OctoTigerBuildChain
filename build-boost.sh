#!/bin/bash -e
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
	. source-me.sh
fi

. source-me.sh
. source-gcc.sh

if [ ! -d "boost_1_68_0/" ]; then
    wget 'http://downloads.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.bz2'
    tar xf boost_1_68_0.tar.bz2
fi
cd boost_1_68_0
echo "using gcc : 8.2 : $CXX ; " >> tools/build/src/user-config.jam
./bootstrap.sh --prefix=$HOME/opt/boost --with-toolset=gcc
./b2 -j${PARALLEL_BUILD} install --with-atomic --with-filesystem --with-program_options --with-regex --with-system --with-chrono --with-date_time --with-thread
cp sign.hpp $HOME/opt/boost/include/boost/spirit/home/support/detail/
