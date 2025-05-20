#!/bin/bash
LLVMROOT=$1
TARGET_CMAKE_FLAGS=$2
RELEASE_BINARY_BASENAME=$3
BUILDER_FLAVOR=$4

BUILD_DIR=$LLVMROOT/_build

set -eux

cmake -G Ninja -S "$LLVMROOT"/llvm -B "$BUILD_DIR" \
            $TARGET_CMAKE_FLAGS \
            -DLLVM_PARALLEL_LINK_JOBS=2 \
            -DCPACK_PACKAGE_FILE_NAME="$RELEASE_BINARY_BASENAME" \
            -DCMAKE_BUILD_TYPE=MinSizeRel \
            -DLLVM_TARGETS_TO_BUILD=host \
            -DLLVM_ENABLE_ASSERTIONS=ON \
            -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF \
            -DLLVM_BUILD_LLVM_DYLIB=ON \
            -DLLVM_LINK_LLVM_DYLIB=ON \
            -DLLVM_ENABLE_ZSTD=OFF \
            -DLLVM_ENABLE_LIBXML2=OFF \
            -DLLVM_ENABLE_CURL=OFF \
            -DLLVM_ENABLE_HTTPLIB=OFF \
            -DLLVM_ENABLE_TERMINFO=OFF \
            -DLLVM_ENABLE_PROJECTS="llvm;clang;lld" \
            -DLLVM_USE_RELATIVE_PATHS_IN_FILES=ON \
            -DCLANG_DEFAULT_LINKER=lld \
            -DCLANG_VENDOR=Tenjin \
            -DCPACK_GENERATOR=TXZ \
            -DCPACK_ARCHIVE_THREADS=0
ls -lh "$BUILD_DIR"
ninja -v -C "$BUILD_DIR"
ls -lh "$BUILD_DIR"

if [ "$BUILDER_FLAVOR" = "docker" ]; then
  # Since Docker is not rootless in GitHub Actions,
  # the files it builds will be owned by root. If
  # we try to package a root-owned build directory,
  # ninja will barf because it cannot overwrite its
  # own cache files. But if we build a tarball that's
  # owned by root, that's fine, since we'll then
  # unpack it, trim the bits we don't need,
  # and re-pack it.
  #
  # We could unconditionally do the packaging step
  # here, even for non-Docker builds, but keeping
  # it separate gives slightly nicer results UI.
  ninja -v -C "$BUILD_DIR" package
fi

