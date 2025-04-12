# Plain options configure the first build.
# BOOTSTRAP_* options configure the second build.

function (set_final_stage_var name value type)
  set(BOOTSTRAP_${name} ${value} CACHE ${type} "")
endfunction()

function (set_instrument_and_final_stage_var name value type)
  # This sets the varaible for the final stage in non-PGO builds and in
  # the stage2-instrumented stage for PGO builds.
  set(BOOTSTRAP_${name} ${value} CACHE ${type} "")
endfunction()

# General Options:
# If you want to override any of the LLVM_RELEASE_* variables you can set them
# on the command line via -D, but you need to do this before you pass this
# cache file to CMake via -C. e.g.
#
# cmake -D LLVM_RELEASE_ENABLE_PGO=ON -C Release.cmake

set (DEFAULT_PROJECTS "clang;lld")
set (DEFAULT_RUNTIMES "compiler-rt;libcxx")
if (NOT WIN32)
  list(APPEND DEFAULT_RUNTIMES "libcxxabi" "libunwind")
endif()
#set(LLVM_RELEASE_ENABLE_LTO THIN CACHE STRING "")
#set(LLVM_RELEASE_ENABLE_PGO ON CACHE BOOL "")
set(LLVM_RELEASE_ENABLE_RUNTIMES ${DEFAULT_RUNTIMES} CACHE STRING "")
set(LLVM_RELEASE_ENABLE_PROJECTS ${DEFAULT_PROJECTS} CACHE STRING "")
# Note we don't need to add install here, since it is one of the pre-defined
# steps.
set(LLVM_RELEASE_FINAL_STAGE_TARGETS
  "clang;package;check-all;check-llvm;check-clang;install-runtimes" CACHE STRING "")
set(CMAKE_BUILD_TYPE RELEASE CACHE STRING "")

# Stage 1 Options
set(LLVM_TARGETS_TO_BUILD Native CACHE STRING "")
set(CLANG_ENABLE_BOOTSTRAP ON CACHE BOOL "")

set(STAGE1_PROJECTS "clang;lld")

# Build all runtimes so we can statically link them into the stage2 compiler.
set(STAGE1_RUNTIMES "compiler-rt;libcxx;libcxxabi;libunwind")

# Any targets added here will be given the target name stage2-${target}, so
# if you want to run them you can just use:
# ninja -C $BUILDDIR stage2-${target}
set(CLANG_BOOTSTRAP_TARGETS ${LLVM_RELEASE_FINAL_STAGE_TARGETS} CACHE STRING "")

set(BOOTSTRAP_LLVM_ENABLE_RUNTIMES "compiler-rt" CACHE STRING "")
set(BOOTSTRAP_LLVM_ENABLE_PROJECTS "clang;lld" CACHE STRING "")

set(RUNTIMES_CMAKE_ARGS "-DLLVM_ENABLE_LLD=ON" CACHE STRING "")

# Stage 1 Common Config
set(LLVM_ENABLE_RUNTIMES ${STAGE1_RUNTIMES} CACHE STRING "")
set(LLVM_ENABLE_PROJECTS ${STAGE1_PROJECTS} CACHE STRING "")
set(LIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY ON CACHE STRING "")

# stage2-instrumented and Final Stage Config:
# Options that need to be set in both the instrumented stage (if we are doing
# a pgo build) and the final stage.
set_instrument_and_final_stage_var(CMAKE_POSITION_INDEPENDENT_CODE "ON" STRING)
#set_instrument_and_final_stage_var(LLVM_ENABLE_LTO "${LLVM_RELEASE_ENABLE_LTO}" STRING)
set_instrument_and_final_stage_var(LLVM_ENABLE_LLD "ON" BOOL)
set_instrument_and_final_stage_var(LLVM_ENABLE_LIBCXX "ON" BOOL)
set_instrument_and_final_stage_var(LLVM_STATIC_LINK_CXX_STDLIB "ON" BOOL)
set(RELEASE_LINKER_FLAGS "-rtlib=compiler-rt --unwindlib=libunwind")
if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
  set(RELEASE_LINKER_FLAGS "${RELEASE_LINKER_FLAGS} -static-libgcc")
endif()

# Set flags for bolt
#if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Linux")
#  set(RELEASE_LINKER_FLAGS "${RELEASE_LINKER_FLAGS} -Wl,--emit-relocs,-znow")
#endif()

set_instrument_and_final_stage_var(CMAKE_EXE_LINKER_FLAGS ${RELEASE_LINKER_FLAGS} STRING)
set_instrument_and_final_stage_var(CMAKE_SHARED_LINKER_FLAGS ${RELEASE_LINKER_FLAGS} STRING)
set_instrument_and_final_stage_var(CMAKE_MODULE_LINKER_FLAGS ${RELEASE_LINKER_FLAGS} STRING)

# Final Stage Config (stage2)
set_final_stage_var(LLVM_ENABLE_RUNTIMES "${LLVM_RELEASE_ENABLE_RUNTIMES}" STRING)
set_final_stage_var(LLVM_ENABLE_PROJECTS "${LLVM_RELEASE_ENABLE_PROJECTS}" STRING)

set_final_stage_var(LLVM_TARGETS_TO_BUILD Native STRING)

set_final_stage_var(LLVM_BUILD_TYPE MinSizeRel STRING)
set_final_stage_var(LLVM_ENABLE_ASSERTIONS "ON" BOOL)

set_final_stage_var(LLVM_BUILD_LLVM_DYLIB "ON" BOOL)
set_final_stage_var(LLVM_LINK_LLVM_DYLIB "ON" BOOL)
set_final_stage_var(LLVM_DYLIB_EXPORT_ALL "ON" BOOL)

set_final_stage_var(CPACK_GENERATOR "TXZ" STRING)
set_final_stage_var(CPACK_ARCHIVE_THREADS "0" STRING)

#set_final_stage_var(CLANG_DEFAULT_CXX_STDLIB "libc++" STRING)

set_final_stage_var(LLVM_ENABLE_ZLIB "OFF" STRING)
set_final_stage_var(LLVM_ENABLE_LIBXML2 "OFF" STRING)
set_final_stage_var(LLVM_ENABLE_TERMINFO "OFF" STRING)
set_final_stage_var(LLVM_USE_STATIC_ZSTD "ON" BOOL)

# Just one less thing to build
set_final_stage_var(CLANG_ENABLE_ARCMT "OFF" BOOL)

# This is to avoid having builder machine paths leak,
# thus making it easier to reproduce the final build.
set_final_stage_var(LLVM_USE_RELATIVE_PATHS_IN_FILES "ON" BOOL)

#set_final_stage_var(DEFAULT_SYSROOT "../clickhouse-sysroot" STRING)

set_final_stage_var(CLANG_VENDOR "Tenjin" STRING)
