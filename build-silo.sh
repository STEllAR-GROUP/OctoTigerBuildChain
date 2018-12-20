#!/bin/bash -e
set -x

. source-gcc.sh

if [ ! -d "silo/" ]; then
    mkdir silo
    cd silo
    if [ ! -d "silo-4.10.2" ]; then
       wget phys.lsu.edu/~dmarcel/silo-4.10.2.tar.gz
    fi
       tar -xvf silo-4.10.2.tar.gz
    cd ..
fi

cd silo
cd silo-4.10.2
cat configure | sed 's/-lhdf5/$hdf5_lib\/libhdf5.a -ldl/g' > tmp
mv tmp configure
chmod 755 configure
autoreconf -ifv
./configure --prefix=$HOME/opt/silo --with-hdf5=$HOME/opt/hdf5/include,$HOME/opt/hdf5/lib/ --enable-optimization

make -j  install

