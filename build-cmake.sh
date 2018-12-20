


if [ ! -d "cmake-3.13.2/" ]; then
   wget https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz
   tar -xf cmake-3.13.2.tar.gz 
   cd cmake-3.13.2
   mkdir build
   cd build
   cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/cmake ..
   make -j 
   make install
fi



