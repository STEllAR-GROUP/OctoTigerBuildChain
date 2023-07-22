### Note: Consider using the [spack octotiger package](https://github.com/G-071/octotiger-spack) instead!

# PowerTiger
Build chain to build octotiger on x86, cray. and ppc64le

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

## Using Modules
Each of the Octo-tiger dependencies also create a module file in build/modules.
To use the modules on systems that use modules, the path has to be added before
a module can be loaded. This is done by running `module use
<powertiger path>/build/modules`.

### Example
```sh
./build-all.sh Release without-cuda
module use build/modules
module add hpx silo
./build/octotiger/build/octotiger ---problem=marshak --radiation=on \
	--rad_implicit=on --odt=1.0e-10 --hard_dt=0.1 --stop_time=2 --gravity=off \
	--hydro=off --max_level=3 --xscale=1.0
```
