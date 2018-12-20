


if [ ! -d "gcc-8.2.0/" ]; then
   wget https://bigsearcher.com/mirrors/gcc/releases/gcc-8.2.0/gcc-8.2.0.tar.gz
   tar -xf gcc-8.2.0.tar.gz 
   cd gcc-8.2.0
   ./contrib/download_prerequisites
   ./configure --prefix=$HOME/opt/gcc --enable-languages=c,c++,fortran
   make -j 
   make install
fi



