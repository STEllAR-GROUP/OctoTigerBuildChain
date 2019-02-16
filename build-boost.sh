#!/usr/bin/env bash

set -ex

BOOST_BUILD_TYPE=$(echo ${BUILDTYPE/%WithDebInfo/ease} | tr '[:upper:]' '[:lower:]')

DIR_SRC=${SOURCE_ROOT}/boost
#DIR_BUILD=${INSTALL_ROOT}/boost/build
DIR_INSTALL=${INSTALL_ROOT}/boost
FILE_MODULE=${INSTALL_ROOT}/modules/boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}

DOWNLOAD_URL="http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION//./_}.tar.bz2"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- ${DOWNLOAD_URL} | tar xj --strip-components=1
        echo "using gcc : : $CXX ; " >>tools/build/src/user-config.jam
    )
fi
#if [[ -d "boost_${BOOST_VERSION//./_}" ]]; then
#    rm -rf boost_${BOOST_VERSION//./_}
#fi
(
    cd ${DIR_SRC}
    ./bootstrap.sh --prefix=${DIR_INSTALL} --with-toolset=gcc
    ./b2 -j${PARALLEL_BUILD} --with-atomic --with-filesystem --with-program_options --with-regex --with-system --with-chrono --with-date_time --with-thread ${BOOST_BUILD_TYPE} install
)
# Patch Boost 1.69 - HPX 1.2 compatibility issue
(
    cp ${BUILD_ROOT}/sign.hpp ${DIR_INSTALL}/include/boost/spirit/home/support/detail/
)

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {boost}
}
module-whatis {boost}
set root    ${DIR_INSTALL}
conflict    boost
prepend-path    CPATH           \$root
prepend-path    LD_LIBRARY_PATH \$root/lib
prepend-path    LIBRARY_PATH    \$root/lib
setenv          BOOST_ROOT      \$root
setenv          BOOST_VERSION   ${BOOST_VERSION}
EOF

