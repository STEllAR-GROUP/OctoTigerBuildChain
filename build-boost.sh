#!/bin/bash -e
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
	. source-me.sh
	. source-gcc.sh
fi


cd $SOURCE_ROOT
if [ ! -f "boost_$BOOST_SUFFIX.tar.bz2" ]; then
    wget http://downloads.sourceforge.net/project/boost/boost/$BOOST_VER/boost_$BOOST_SUFFIX.tar.bz2
fi
tar xf boost_$BOOST_SUFFIX.tar.bz2
cd boost_$BOOST_SUFFIX
echo "using gcc : 8.2 : $CXX ; " >> tools/build/src/user-config.jam
./bootstrap.sh --prefix=$BOOST_ROOT --with-toolset=gcc
./b2 -j${PARALLEL_BUILD} install --with-atomic --with-filesystem --with-program_options --with-regex --with-system --with-chrono --with-date_time --with-thread cd ..
cp sign.hpp $BOOST_ROOT/include/boost/spirit/home/support/detail/
