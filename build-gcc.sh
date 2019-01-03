


if [ ! -d "gcc-7.4.0/" ]; then
   wget https://bigsearcher.com/mirrors/gcc/releases/gcc-7.4.0/gcc-7.4.0.tar.gz
   tar -xf gcc-7.4.0.tar.gz 
   cd gcc-7.4.0
   ./contrib/download_prerequisites
   ./configure --prefix=$HOME/opt/gcc --enable-languages=c,c++,fortran
   make -j 
   make install
fi



