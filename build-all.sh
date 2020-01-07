#!/usr/bin/env bash

################################################################################
# Command-line help
################################################################################
print_usage_abort ()
{
    cat <<EOF >&2
SYNOPSIS
    ${0} {Release|RelWithDebInfo|Debug} {with-cuda|without-cuda}
    [cmake|gcc|boost|hdf5|silo|hwloc|jemalloc|vc|hpx|octotiger|openmpi ...]
DESCRIPTION
    Download, configure, build, and install Octo-tiger and its dependencies or
    just the specified target.
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
    print_usage_abort
fi

if [[ "$2" == "without-cuda" ]]; then
    export OCT_WITH_CUDA=OFF
    echo "CUDA Support: Disabled"
elif [[ "$2" == "with-cuda" ]]; then
    export OCT_WITH_CUDA=ON
    echo "CUDA Support: Enabled"
else
    echo 'CUDA support must be specified and has to be "with-cuda" or "without-cuda"' >&2
    print_usage_abort
fi

if [[ "$3" == "without-mpi" ]]; then
    export OCT_WITH_PARCEL=OFF
    echo "Parcelport disabled"
elif [[ "$3" == "with-mpi" ]]; then
    export OCT_WITH_PARCEL=ON
    echo "Parcelport enabled"
else
    echo 'Parcelport support must be provided and has to be "with-mpi" or "without-mpi"' >&2
    print_usage_abort
fi

while [[ -n $4 ]]; do
    case $4 in
        cmake)
            echo 'Target cmake will build.'
            export BUILD_TARGET_CMAKE=
            shift
        ;;
        gcc)
            echo 'Target gcc will build.'
            export BUILD_TARGET_GCC=
            shift
        ;;
        openmpi)
            echo 'Target openmpi will build.'
            export BUILD_TARGET_OPENMPI=
            shift
        ;;

        boost)
            echo 'Target boost will build.'
            export BUILD_TARGET_BOOST=
            shift
        ;;
        hdf5)
            echo 'Target hdf5 will build.'
            export BUILD_TARGET_HDF5=
            shift
        ;;
        silo)
            echo 'Target silo will build.'
            export BUILD_TARGET_SILO=
            shift
        ;;
        hwloc)
            echo 'Target hwloc will build.'
            export BUILD_TARGET_HWLOC=
            shift
        ;;
        jemalloc)
            echo 'Target jemalloc will build.'
            export BUILD_TARGET_JEMALLOC=
            shift
        ;;
        vc)
            echo 'Target vc will build.'
            export BUILD_TARGET_VC=
            shift
        ;;
        hpx)
            echo 'Target hpx will build.'
            export BUILD_TARGET_HPX=
            shift
        ;;
        Yoctotiger)
            echo 'Target octotiger will build.'
            export BUILD_TARGET_OCTOTIGER=
            shift
        ;;
        libfabric)
            echo 'Target libfabric will build.'
            export BUILD_TARGET_LIBFABRIC=
            shift
        ;;
        *)
            echo 'Unrecognizable argument passesd.' >&2
            print_usage_abort
        ;;
    esac
done

# Build all if no target(s) specified
if [[ -z ${!BUILD_TARGET_@} ]]; then
    echo 'No targets specified. All targets will build.'
    export BUILD_TARGET_CMAKE=
    export BUILD_TARGET_GCC=
    export BUILD_TARGET_OPENMPI=
    export BUILD_TARGET_BOOST=
    export BUILD_TARGET_HDF5=
    export BUILD_TARGET_SILO=
    export BUILD_TARGET_HWLOC=
    export BUILD_TARGET_JEMALLOC=
    export BUILD_TARGET_VC=
    export BUILD_TARGET_HPX=
    export BUILD_TARGET_OCTOTIGER=
    export BUILD_TARGET_LIBFABRIC=
fi

if [[ -d "/etc/opt/cray/release/" ]]; then
    unset BUILD_TARGET_GCC
    unset BUILD_TARGET_OPENMPI
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

# Set Build Configuration Parameters
source config.sh

################################################################################
# Create source and installation directories
################################################################################
mkdir -p ${SOURCE_ROOT} ${INSTALL_ROOT}

################################################################################
# Build tools
################################################################################
[[ -n ${BUILD_TARGET_GCC+x} ]] && \
(
    echo "Building GCC"
    ./build-gcc.sh
)

[[ -n ${BUILD_TARGET_CMAKE+x} ]] && \
(
    echo "Building CMake"
    ./build-cmake.sh
)
export CMAKE_COMMAND=${INSTALL_ROOT}/cmake/bin/cmake

################################################################################
# Dependencies
################################################################################
# Set GCC Environment Variables
source gcc-config.sh

[[ -n ${BUILD_TARGET_OPENMPI+x} ]] && \
(
    echo "Building Openmpi"
    ./build-openmpi.sh
)

if [[ ${OCT_WITH_PARCEL} == ON  ]]; then    
   if [[ -d ${INSTALL_ROOT}/openmpi  ]]; then
	source openmpi-config.sh
   fi
fi

[[ -n ${BUILD_TARGET_BOOST+x} ]] && \
(
    echo "Building Boost"
    ./build-boost.sh
)
[[ -n ${BUILD_TARGET_HDF5+x} ]] && \
(
    echo "Building HDF5"
    ./build-hdf5.sh
)
[[ -n ${BUILD_TARGET_SILO+x} ]] && \
(
    echo "Building Silo"
    ./build-silo.sh
)
[[ -n ${BUILD_TARGET_HWLOC+x} ]] && \
(
    echo "Building hwloc"
    ./build-hwloc.sh
)
[[ -n ${BUILD_TARGET_JEMALLOC+x} ]] && \
(
    echo "Building jemalloc"
    ./build-jemalloc.sh
)
[[ -n ${BUILD_TARGET_VC+x} ]] && \
(
    echo "Building Vc"
    ./build-Vc.sh
)
[[ -n ${BUILD_TARGET_HPX+x} ]] && \
(
    echo "Building HPX"
    ./build-hpx.sh
)
[[ -n ${BUILD_TARGET_LIBFABRIC+x} ]] && \
(
    echo "Building LIBFABRIC"
    ./build-libfabric.sh
)
################################################################################
# Octo-tiger
################################################################################
[[ -n ${BUILD_TARGET_OCTOTIGER+x} ]] && \
(
    echo "Building Octo-tiger"
    ./build-octotiger.sh
)
