. souce-gcc.sh


if [ ! -d "jemalloc-5.0.1/" ]; then
   wget https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2
   tar -xf jemalloc-5.1.0.tar.bz2
   cd jemalloc-5.1.0
   ./autogen.sh
   ./configure --prefix=$HOME/opt/jemalloc
   make -j 
   make install
fi



