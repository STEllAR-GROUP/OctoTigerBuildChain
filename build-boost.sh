#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${CXX:?} \
    ${BOOST_VERSION:?} ${BOOST_BUILD_TYPE:?} ${POWERTIGER_ROOT:?}

if [[ -d "/etc/opt/cray/release/" ]]; then 
	flag1="cxxflags=$CXXFLAGS"
        flag2="threading=multi link=shared"
else
	flag1=""
	flag2=""
fi

DIR_SRC=${SOURCE_ROOT}/boost
#DIR_BUILD=${INSTALL_ROOT}/boost/build
DIR_INSTALL=${INSTALL_ROOT}/boost
FILE_MODULE=${INSTALL_ROOT}/modules/boost/${BOOST_VERSION}-${BOOST_BUILD_TYPE}

#DOWNLOAD_URL="http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION//./_}.tar.bz2"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        # Get from sourceforge
        #mkdir -p ${DIR_SRC}
        #cd ${DIR_SRC}
	# When using the sourceforge link
        #wget -O- ${DOWNLOAD_URL} | tar xj --strip-components=1

	# Get super repository variant 1 (get entire super project)
	#cd ${SOURCE_ROOT}
	#git clone https://github.com/boostorg/boost boost
	#cd boost
	# Get correct version before getting the submodules
	#git checkout boost-${BOOST_VERSION}
	# NOTE: Rerun all submodule inits when switchting the version using this variant...

	# Get super repository variant 2 (get only the correct commit)
	cd ${SOURCE_ROOT}
	git clone --depth 1 --branch boost-${BOOST_VERSION} https://github.com/boostorg/boost boost

	cd boost
	# checkout required tools
	git submodule update --init --recursive tools/build/
	git submodule update --init --recursive tools/boost_install/
	# checkout basic lib submodules
	git submodule update --init --recursive libs/headers/
	git submodule update --init --recursive libs/core/
	git submodule update --init --recursive libs/type_traits/
	git submodule update --init --recursive libs/static_assert/
	git submodule update --init --recursive libs/assert/
	git submodule update --init --recursive libs/iterator/
	git submodule update --init --recursive libs/array/
	git submodule update --init --recursive libs/config/
	git submodule update --init --recursive libs/io/
	# checkout actual compoments that we want
	git submodule update --init --recursive libs/thread/
	git submodule update --init --recursive libs/iostreams/
	git submodule update --init --recursive libs/date_time/
	git submodule update --init --recursive libs/chrono/
	git submodule update --init --recursive libs/system/
	git submodule update --init --recursive libs/regex/
	git submodule update --init --recursive libs/program_options/
	git submodule update --init --recursive libs/filesystem/
	git submodule update --init --recursive libs/atomic/
	git submodule update --init --recursive libs/spirit/
	# Adapt as needed for other stuff

        echo "using gcc : : $CXX ; " >tools/build/src/user-config.jam
    )
fi
#if [[ -d "boost_${BOOST_VERSION//./_}" ]]; then
#    rm -rf boost_${BOOST_VERSION//./_}
#fi
(
    cd ${DIR_SRC}
    if [[ "${OCT_WITH_CLANG}" == "ON" ]]; then
        ./bootstrap.sh --prefix=${DIR_INSTALL} --with-toolset=clang
    else
        ./bootstrap.sh --prefix=${DIR_INSTALL} --with-toolset=gcc
    fi
    ./b2 -j${PARALLEL_BUILD} "${flag1}" ${flag2} --with-atomic --with-filesystem --with-program_options --with-regex --with-system --with-chrono --with-date_time --with-thread --with-iostreams ${BOOST_BUILD_TYPE} install
)
# Patch Boost 1.69 - HPX 1.2 compatibility issue
cp ${POWERTIGER_ROOT}/sign.hpp ${DIR_INSTALL}/include/boost/spirit/home/support/detail/

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {boost}
}
module-whatis {boost}
set root    ${DIR_INSTALL}
conflict    boost
module load gcc/${GCC_VERSION}
prereq      gcc/${GCC_VERSION}
prepend-path    CPATH           \$root
prepend-path    LD_LIBRARY_PATH \$root/lib
prepend-path    LIBRARY_PATH    \$root/lib
setenv          BOOST_ROOT      \$root
setenv          BOOST_VERSION   ${BOOST_VERSION}
EOF

