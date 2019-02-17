#!/usr/bin/env bash

################################################################################
# Command-line help
################################################################################
print_synopsis ()
{
    cat <<EOF >&2
SYNOPSIS
    ${0} {Release|RelWithDebInfo|Debug} {with-cuda|without-cuda}
DESCRIPTION
    Download, configure, build, and install Octo-tiger and its dependencies
EOF
    exit 1
}

################################################################################
# Command-line options
################################################################################
if [[ "$1" == "Release" || "$1" == "RelWithDebInfo" || "$1" == "Debug" ]]; then
    export BUILD_TYPE=$1
    echo "Build Type: ${BUILD_TYPE}"
else
    echo 'Build type must be provided and has to be "Release", "RelWithDebInfo", or "Debug"' >&2
    print_synopsis
fi

if [[ "$2" == "without-cuda" ]]; then
    export OCT_WITH_CUDA=OFF
    echo "CUDA Support: Enabled"
elif [[ "$2" == "with-cuda" ]]; then
    export OCT_WITH_CUDA=ON
    echo "CUDA Support: Disabled"
else
    echo 'CUDA support must be specified and has to be "with-cuda"  or "without-cuda"' >&2
    print_synopsis
fi

################################################################################
# Diagnostics
################################################################################
set -e
set -x

################################################################################
# Configuration
################################################################################
# Script directory
export POWERTIGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd )"

# Build Configuration Parameters
source source-me.sh

################################################################################
# Create source and installation directories
################################################################################
mkdir -p ${SOURCE_ROOT} ${INSTALL_ROOT}

################################################################################
# Build tools
################################################################################
echo "Building GCC"
./build-gcc.sh
echo "Building CMake"
./build-cmake.sh
export CMAKE_COMMAND=${INSTALL_ROOT}/cmake/bin/cmake

################################################################################
# Dependencies
################################################################################
source source-gcc.sh
echo "Building Boost"
./build-boost.sh
echo "Building HDF5"
./build-hdf5.sh
echo "Building Silo"
./build-silo.sh
echo "Building hwloc"
./build-hwloc.sh
echo "Building jemalloc"
./build-jemalloc.sh
echo "Building Vc"
./build-Vc.sh
echo "Building HPX"
./build-hpx.sh

################################################################################
# Octo-tiger
################################################################################
echo "Building Octo-tiger"
./build-octotiger.sh

