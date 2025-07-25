CMAKE_MINIMUM_REQUIRED(VERSION 3.12)

PROJECT(letus_prototype)
find_package(OpenSSL 1.1 REQUIRED)
# find_package(GTest REQUIRED)
enable_testing()
# 查找glibc
# find_package(PkgConfig REQUIRED)
pkg_check_modules(GNUC standard glibc >= 2.34)

include_directories(${OPENSSL_INCLUDE_DIR})

if(APPLE)
    # Get LLVM prefix from homebrew
    execute_process(
        COMMAND brew --prefix llvm
        OUTPUT_VARIABLE LLVM_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    # Add standard C++ library paths
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
        -isystem ${LLVM_PREFIX}/include/c++/v1 \
        -isystem /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include \
        -isystem /opt/homebrew/include \
        -isystem /usr/local/include"
    )
    
    # Set the C++ compiler to use LLVM clang++
    set(CMAKE_CXX_COMPILER "${LLVM_PREFIX}/bin/clang++")
endif()

# set(CMAKE_CXX_COMPILER "g++-11")
# set(CMAKE_CXX_COMPILER "clang++")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -O2 -pthread -lssl -Wall -Wno-unused-function -fPIC")
# 添加 AddressSanitizer 标志
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -g -DDEBUG -fPIC -fno-omit-frame-pointer")
# set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -g -DDEBUG -fPIC -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O2 -fPIC -mcmodel=medium" )
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS}")
# set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
# set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

aux_source_directory(lib/ letus_lib)
aux_source_directory(src/ letus_src)
aux_source_directory(test/ letus_tests)
# aux_source_directory(workload/lib/ workload_lib)

include_directories(${OPENSSL_INCLUDE_DIR})
include_directories(lib/)
include_directories(workload/lib/)

# add_executable(trace_replay "workload/exes/trace_replay.cc")
# add_executable(trace_replay "workload/exes/trace_replay.cc" ${letus_lib})
# target_link_libraries(trace_replay jsoncpp)

add_executable(microBenchmark "workload/exes/microBenchmark.cc" ${letus_src})
target_link_libraries(microBenchmark OpenSSL::SSL OpenSSL::Crypto ${GNUC_LIBRARIES})
add_executable(rangeBenchmark "workload/exes/rangeBenchmark.cc" ${letus_src})
target_link_libraries(rangeBenchmark OpenSSL::SSL OpenSSL::Crypto ${GNUC_LIBRARIES})
add_executable(updateBenchmark "workload/exes/updateBenchmark.cc" ${letus_src})
target_link_libraries(updateBenchmark OpenSSL::SSL OpenSSL::Crypto ${GNUC_LIBRARIES})
add_executable(lineageBenchmark "workload/exes/lineageBenchmark.cc" ${letus_src})
target_link_libraries(lineageBenchmark OpenSSL::SSL OpenSSL::Crypto ${GNUC_LIBRARIES})
# add_executable(LSVPStest ${letus_tests})
# target_link_libraries(LSVPStest letus GTest::GTest GTest::Main)

add_library(letus STATIC ${letus_lib} ${letus_src})
target_link_libraries(letus OpenSSL::SSL OpenSSL::Crypto)
# add_test(NAME LSVPStest COMMAND LSVPStest)