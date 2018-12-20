. source-gcc.sh


if [ ! -d "hwloc-1.11.12/" ]; then
   wget https://download.open-mpi.org/release/hwloc/v1.11/hwloc-1.11.12.tar.gz
   tar -xf hwloc-1.11.12.tar.gz 
   cd hwloc-1.11.12
   ./configure --prefix=$HOME/opt/hwloc/ --disable-opencl 
   make -j 
   make install
fi



