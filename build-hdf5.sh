. source-gcc.sh


if [ ! -d "hdf5/" ]; then
    git clone https://github.com/live-clones/hdf5
else
    cd hdf5
    git pull
    cd ..
fi

cd hdf5
git checkout hdf5_1_10_4 
mkdir -p build
cd build
$HOME/opt/cmake/bin/cmake \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DBUILD_TESTING=OFF \                                                          -DCMAKE_BUILD_TYPE=Release \                                                     -DCMAKE_INSTALL_PREFIX=$HOME/opt/hdf5 \
	..

make -j VERBOSE=1 install

