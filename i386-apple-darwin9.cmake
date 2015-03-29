SET(CMAKE_SYSTEM_NAME Darwin-GNU)
SET(CMAKE_C_COMPILER i386-apple-darwin9-gcc)
SET(CMAKE_CXX_COMPILER i386-apple-darwin9-g++)
SET(_CMAKE_TOOLCHAIN_PREFIX i386-apple-darwin9-)
EXECUTE_PROCESS(COMMAND i386-apple-darwin9-gcc -print-sysroot OUTPUT_VARIABLE CMAKE_FIND_ROOT_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(ZLIB_LIBRARY ${CMAKE_FIND_ROOT_PATH}/usr/lib/libz.dylib)
SET(ZLIB_INCLUDE_DIR ${CMAKE_FIND_ROOT_PATH}/usr/include)