#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/boost
#DIR_BUILD=${INSTALL_ROOT}/boost/build
DIR_INSTALL==${INSTALL_ROOT}/boost

DOWNLOAD_URL="http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_SUFFIX}.tar.bz2"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- ${DOWNLOAD_URL} | tar xJ --strip-components=1
    )
fi
#if [[ -d "boost_$BOOST_SUFFIX" ]]; then
#    rm -rf boost_$BOOST_SUFFIX
#fi
(
    cd ${DIR_SRC}
    echo "using gcc : 8.2 : $CXX ; " >>tools/build/src/user-config.jam
    ./bootstrap.sh --prefix=${DIR_INSTALL} --with-toolset=gcc
    ./b2 -j${PARALLEL_BUILD} install --with-atomic --with-filesystem --with-program_options --with-regex --with-system --with-chrono --with-date_time --with-thread 
)
# Patch Boost 1.69 - HPX 1.2 compatibility issue
(
    cd ${DIR_INSTALL}
    cp ${BUILD_ROOT}/sign.hpp ${DIR_INSTALL}/include/boost/spirit/home/support/detail/
)

