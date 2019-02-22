# PowerTiger
Build chain to build octotiger on x86 and ppc64le

## Usage

### Synopsis
    build-all.sh {Release|RelWithDebInfo|Debug} {with-cuda|without-cuda} 
    [cmake|gcc|boost|hdf5|silo|hwloc|jemalloc|vc|hpx|octotiger ...]

### Description
Download, configure, build, and install Octo-tiger and its dependencies or
just the specified target(s).

### Example
* Build Octo-tiger and dependencies without CUDA support in Release mode
    * `./build-all.sh Release without-cuda`
* Build GCC
    * `./build-all.sh Release without-cuda gcc`
* Build GCC and CMake
    * `./build-all.sh Release without-cuda gcc cmake`
* Build Octo-tiger, Vc, HPX, and Boost with CUDA support in Debug
    * `./build-all.sh Debug with-cuda octotiger vc hpx boost`

## Notes
* Target builds do not check for an existing build.
* Building a target does not trigger the build of it dependencies if they are not built