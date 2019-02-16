#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/Vc
DIR_BUILD=${INSTALL_ROOT}/Vc/build
DIR_INSTALL==${INSTALL_ROOT}/Vc

if [[ ! -d ${DIR_SRC} ]]; then
    git clone --branch=1.4.1 --depth=1 https://github.com/VcDevel/Vc.git ${DIR_SRC}
fi

${CMAKE} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF

${CMAKE} --build ${DIR_BUILD} --target install -- -j${PARALLEL_BUILD} VERBOSE=1

