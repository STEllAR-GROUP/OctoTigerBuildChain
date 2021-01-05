#!/usr/bin/env bash

################################################################################
# Command-line help
################################################################################
print_usage_abort ()
{
    cat <<EOF >&2
SYNOPSIS
    ${0} {Release|RelWithDebInfo|Debug} {with-gcc|with-clang|with-CC|with-CC-clang} {with-cuda|without-cuda} 
    {with-mpi,without-mpi,with-libfabric} {with-papi,without-papi} {with-apex,without-apex} {with-kokkos,without-kokkos}
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

if [[ "$2" == "with-gcc" ]]; then
    export OCT_WITH_CUDA=OFF
    echo "Using self-built gcc "
elif [[ "$2" == "with-CC" ]]; then
    echo "Using CC / CXX compiler (whatever it may be)"
    export OCT_USE_CC_COMPILER=ON
elif [[ "$2" == "with-CC-clang" ]]; then
    echo "Using CC / CXX compiler (but expecting it to be some kind of clang)"
    export OCT_WITH_CLANG=ON
    export OCT_USE_CC_COMPILER=ON
elif [[ "$2" == "with-clang" ]]; then
    echo "Using self-built clang "
    export OCT_WITH_CLANG=ON
else
    echo 'Compiler must be specified with "with-gcc" or "with-clang" or "with-CC" or "with-CC-clang' >&2
    print_usage_abort
fi
export OCT_COMPILER_OPTION="$2"

if [[ "$3" == "without-cuda" ]]; then
    export OCT_WITH_CUDA=OFF
    echo "CUDA Support: Disabled"
elif [[ "$3" == "with-cuda" ]]; then
    export OCT_WITH_CUDA=ON
    echo "CUDA Support: Enabled"
else
    echo 'CUDA support must be specified and has to be "with-cuda" or "without-cuda"' >&2
    print_usage_abort
fi

if [[ "$4" == "without-mpi" ]]; then
    export OCT_WITH_PARCEL=OFF
    echo "Parcelport disabled"
elif [[ "$4" == "with-mpi" ]]; then
    export OCT_WITH_PARCEL=ON
    export OCT_WITH_LIBFABRIC=OFF
    echo "Parcelport enabled"
elif [[ "$4" == "with-libfabric" ]]; then
    export OCT_WITH_LIBFABRIC=ON
    export OCT_WITH_PARCEL=OFF
    echo "Parcelport enabled"
else
    echo 'Parcelport support must be provided and has to be "with-mpi" or "without-mpi or "with-libfabric""' >&2
    print_usage_abort
fi


if [[ "$5" == "without-papi" ]]; then
    export OCT_WITH_PAPI=OFF
    echo "PAPI disabled"
elif [[ "$5" == "with-papi" ]]; then
    export OCT_WITH_PAPI=ON
#    export BUILD_TARGET_PAPI=
    echo "PAPI enabled"
else
    echo 'PAPI support must be provided and has to be "with-papi" or "without-papi"' >&2
    print_usage_abort
fi

if [[ "$6" == "without-apex" ]]; then
    export OCT_WITH_APEX=OFF
    echo "APEX disabled"
elif [[ "$6" == "with-apex" ]]; then
    export OCT_WITH_APEX=ON
    echo "APEX enabled"
else
    echo 'APEX support must be provided and has to be "with-apex" or "without-apex"' >&2
    print_usage_abort
fi

if [[ "$7" == "without-kokkos" ]]; then
    echo "KOKKOS disabled"
    export OCT_WITH_KOKKOS=OFF
    echo "KOKKOS disabled"
elif [[ "$7" == "with-kokkos" ]]; then
    echo "KOKKOS enabled"
    export OCT_WITH_KOKKOS=ON
    if [[ "${OCT_WITH_CLANG}" == "ON" ]]; then
        echo 'clang and octotiger-kokkos currently do not work together!' >&2
        print_usage_abort
    fi
else
    echo 'KOKKOS support must be provided and has to be "with-kokkos" or "without-kokkos"' >&2
    print_usage_abort
fi

while [[ -n $8 ]]; do
    case $8 in
        cmake)
            echo 'Target cmake will build.'
            export BUILD_TARGET_CMAKE=
            shift
        ;;
        gcc)
            if [[ "$2" == "with-gcc" ]]; then
              echo 'Target gcc will build.'
              export BUILD_TARGET_GCC=
              shift
            else  
              echo 'Error: Trying to build gcc target without using the with-gcc parameter' >&2
              print_usage_abort
            fi
        ;;
        clang)
            if [[ "$2" == "with-clang" ]]; then
              echo 'Target clang will build.'
              export BUILD_TARGET_CLANG=
              shift
            else  
              echo 'Error: Trying to build clang target without using the with-clang parameter' >&2
              print_usage_abort
            fi
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
        kokkos)
            echo 'Target kokkos will build.'
            export BUILD_TARGET_KOKKOS=
            shift
        ;;
        cppuddle)
            echo 'Target cppuddle will build.'
            export BUILD_TARGET_CPPUDDLE=
            shift
        ;;
        octotiger)
            echo 'Target octotiger will build.'
            export BUILD_TARGET_OCTOTIGER=
            shift
        ;;
        libfabric)
	    if [[ "$3" == "with-libfabric" ]]; then
                echo 'Target libfabric will build.'
                export BUILD_TARGET_LIBFABRIC=
            fi
            shift
	;;
	papi)
	    if [[ "$4" == "with-papi" ]]; then
                echo 'Target papi will build.'
                export BUILD_TARGET_PAPI=
            fi
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
    if [[ "$2" == "with-gcc" ]]; then
      export BUILD_TARGET_GCC=
    elif [[ "$2" == "with-clang" ]]; then
        export BUILD_TARGET_CLANG=
    fi
    if [[ "$4" == "with-mpi" ]]; then
        export BUILD_TARGET_OPENMPI=
    fi
    export BUILD_TARGET_BOOST=
    export BUILD_TARGET_HDF5=
    export BUILD_TARGET_SILO=
    export BUILD_TARGET_HWLOC=
    export BUILD_TARGET_JEMALLOC=
    export BUILD_TARGET_VC=
    export BUILD_TARGET_HPX=
    export BUILD_TARGET_OCTOTIGER=
    export BUILD_TARGET_CPPUDDLE=
    if [[ "$4" == "with-libfabric" ]]; then
        export BUILD_TARGET_LIBFABRIC=
    fi
    if [[ "$5" == "with-papi" ]]; then
        export BUILD_TARGET_PAPI=
    fi
    if [[ "$6" == "with-apex" ]]; then
        export BUILD_TARGET_APEX=
    fi
    if [[ "$7" == "with-kokkos" ]]; then
        export BUILD_TARGET_KOKKOS=
    fi
fi

if [[ -d "/etc/opt/cray/release/" ]]; then
    unset BUILD_TARGET_GCC
    unset BUILD_TARGET_CLANG
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
[[ -n ${BUILD_TARGET_CLANG+x} ]] && \
(
    echo "Building clang"
    ./build-clang.sh
)

# Set Compiler Environment Variables
if [[ "${OCT_COMPILER_OPTION}" == "with-gcc" ]]; then
    echo "Using gcc"
    source gcc-config.sh
elif [[ "${OCT_COMPILER_OPTION}" == "with-clang" ]]; then
    echo "Using clang"
    source clang-config.sh
elif [[ "${OCT_COMPILER_OPTION}" == "with-CC" ]]; then
    export OCT_USE_CC_COMPILER=ON
    source gcc-config.sh
elif [[ "${OCT_COMPILER_OPTION}" == "with-CC-clang" ]]; then
    echo "Using clang"
    export OCT_USE_CC_COMPILER=ON
    source clang-config.sh
else
    echo "Unknown compiler option: $2"
    exit 1
fi


[[ -n ${BUILD_TARGET_CMAKE+x} ]] && \
(
    echo "Building CMake"
    ./build-cmake.sh
)
export CMAKE_COMMAND=${INSTALL_ROOT}/cmake/bin/cmake
#export CMAKE_COMMAND=cmake

################################################################################
# Dependencies
################################################################################

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
[[ -n ${BUILD_TARGET_PAPI+x} ]] && \
(
    echo "Building PAPI"
    ./build-papi.sh
)
[[ -n ${BUILD_TARGET_HPX+x} ]] && \
(
    echo "Building HPX"
    ./build-hpx.sh
)
[[ -n ${BUILD_TARGET_KOKKOS+x} ]] && \
(
    echo "Building KOKKOS"
    ./build-kokkos.sh
    echo "Building KOKKOS-HPX"
    ./build-hpx-kokkos.sh
)
[[ -n ${BUILD_TARGET_CPPUDDLE+x} ]] && \
(
    echo "Building CPPuddle"
    ./build-cppuddle.sh
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
