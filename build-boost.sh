#!/bin/bash -e
set -x

. source-gcc.sh

if [ ! -d "boost_1_68_0/" ]; then
    wget 'http://downloads.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.bz2'
    tar xf boost_1_68_0.tar.bz2
    cd boost_1_68_0
    ./bootstrap.sh --prefix=$HOME/opt/boost --with-toolset=gcc
    ./b2 -j 20 install --with-atomic --with-filesystem --with-program_options --with-regex --with-system --with-chrono --with-date_time --with-thread
fi
