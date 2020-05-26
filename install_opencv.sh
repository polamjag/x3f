#!/bin/bash

if [ -z $1 ]; then
    echo usage $0 "<TARGET> [<cmake toolchain file>]"
    echo Please run '"make"'
    exit 1
else
    TARGET=$1
fi

CORES=`nproc 2>/dev/null`
if [ $? -eq 0 ]; then
    echo Detected $CORES cores
else
    CORES=4
    echo Unable to detect number of cores, assuming $CORES
fi

ROOT=$PWD
SRC=$ROOT/deps/src
LIB=$ROOT/deps/lib/$TARGET

OCV_SRC=$SRC/opencv
OCV_BLD=$SRC/$TARGET/opencv_build
OCV_LIB=$LIB/opencv

OCV_URL=https://github.com/opencv/opencv.git
OCV_HASH=master

OCV_FLAGS="-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -D CMAKE_CXX_FLAGS=-stdlib=libc++ \
           -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_SHARED_LIBS=OFF \
           -D WITH_IPP=OFF -D WITH_TBB=ON -D BUILD_TBB=ON \
           -D BUILD_TIFF=ON -D WITH_JPEG=OFF -D WITH_JASPER=OFF \
           -D WITH_PNG=OFF -D WITH_WEBP=OFF -D WITH_OPENEXR=OFF \
           -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_DOCS=OFF \
           -D BUILD_opencv_python2=OFF -D BUILD_opencv_python3=OFF \
           -D BUILD_opencv_java=OFF -D BUILD_opencv_apps=OFF \
           -D WITH_PROTOBUF=OFF -D WITH_ITT=ON -D BUILD_ITT=ON \
           -D ENABLE_SSE41=ON -D ENABLE_SSE42=ON -D ENABLE_AVX=ON -D ENABLE_AVX2=ON -D TEST_BIG_ENDIAN=OFF"
OPENCV_EXTRA_FLAGS=""

if [[ $TARGET =~ ^osx- ]]; then
    if [ `uname -s` = Darwin ]; then
	OPENCV_EXTRA_FLAGS="$OPENCV_EXTRA_FLAGS \
                            -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    else
	# APPLE and UNIX are not defined automatically when cross-compiling
	OCV_FLAGS="$OCV_FLAGS -D APPLE=1 -D UNIX=1"
	# Precompiled headers do not work with OSXCross
    OCV_FLAGS="$OCV_FLAGS -D ENABLE_PRECOMPILED_HEADERS=OFF"
	# Workaround for cmake bug
	mkdir -p $SRC/cmake_workaround || exit 1
	TOOL=x86_64-apple-darwin11-install_name_tool
	TOOL_PATH=`which $TOOL` || {
	    echo Could not find $TOOL
	    echo Make sure to run '`osxcross-env`' to set PATH
	    exit 1
	}
	ln -fs $TOOL_PATH $SRC/cmake_workaround/install_name_tool || exit 1
	PATH="$PATH:$SRC/cmake_workaround"
    fi
    OPENCV_EXTRA_FLAGS="$OPENCV_EXTRA_FLAGS -mmacosx-version-min=10.9 \
                        -arch `echo $TARGET | sed 's/^osx-//'` -Wno-pragmas"
fi

if [[ $TARGET =~ ^windows- ]]; then
    OCV_FLAGS="$OCV_FLAGS -D BUILD_ZLIB=ON \
                          -D OPENCV_EXTRA_CXX_FLAGS=-DUSE_WINTHREAD"
else
    OCV_FLAGS="$OCV_FLAGS -D OPENCV_EXTRA_CXX_FLAGS=-DUSE_PTHREAD"
fi

if [ -n "$2" ]; then
    OCV_FLAGS="$OCV_FLAGS -D CMAKE_TOOLCHAIN_FILE=$ROOT/$2"
fi

if [ -e $OCV_SRC ]; then
    echo Fetch opencv
    cd $OCV_SRC || exit 1
    git fetch || exit 1
else
    echo Clone opencv
    mkdir -p $SRC || exit 1
    git clone --depth 1 $OCV_URL $OCV_SRC || exit 1
    cd $OCV_SRC || exit 1
fi

echo Build Opencv
git checkout $OCV_HASH || exit 1
mkdir -p $OCV_BLD || exit 1
mkdir -p $OCV_LIB || exit 1
cd $OCV_BLD || exit 1
cmake $OCV_FLAGS -D OPENCV_EXTRA_FLAGS="$OPENCV_EXTRA_FLAGS" \
      -D CMAKE_INSTALL_PREFIX=$OCV_LIB $OCV_SRC || exit 1
make -j $CORES install || exit 1
touch $OCV_LIB/.success || exit 1
echo Successfully installed OpenCV in $OCV_LIB
