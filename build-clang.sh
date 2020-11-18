#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${CLANG_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/llvm-project
DIR_BUILD=${INSTALL_ROOT}/clang/build
DIR_INSTALL=${INSTALL_ROOT}/clang


cd "${SOURCE_ROOT}"
mkdir -p llvm-project
cd llvm-project
if [ ! -d llvm ] ; then
    git clone https://llvm.org/git/llvm.git
    cd llvm
    #git checkout release_60
    git checkout "${CLANG_VERSION}"
#    git checkout d42d9e83aeb0e752cec99b1a1f2b17a9246bff27
    cd ..
fi
if [ ! -d clang ] ; then
    git clone https://llvm.org/git/clang.git
    cd clang
    #git checkout release_60
    git checkout "${CLANG_VERSION}"
#    git checkout 23b713ddc4e7f70cd6e96ea93eab3f06ca3a72d7
    cd ..
fi
if [ ! -d libcxx ] ; then
    git clone https://llvm.org/git/libcxx.git
    cd libcxx
    #git checkout release_60
    git checkout "${CLANG_VERSION}"
#    git checkout 0b261846c90cdcfa6e584a5048665a999900618f
    cd ..
fi
if [ ! -d libcxxabi ] ; then
    git clone https://llvm.org/git/libcxxabi.git
    cd libcxxabi
    #git checkout release_60
    git checkout "${CLANG_VERSION}"
#    git checkout 565ba0415b6b17bbca46820a0fcfe4b6ab5abce2
    cd ..
fi

mkdir -p "${DIR_BUILD}"
cd "${DIR_BUILD}"
#mkdir -p llvm-build && cd llvm-build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$DIR_INSTALL/clang -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" -DLLVM_TARGETS_TO_BUILD="X86;NVPTX;PowerPC" "${DIR_SRC}/llvm"
make -j${PARALLEL_BUILD} install

cd $BUILD_ROOT
