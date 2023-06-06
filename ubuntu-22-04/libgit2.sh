#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../libgit2/"
build_path="$root_path/libgit2_build"
install_path="$root_path/libgit2_install"


ZLIB_ROOT_install="$root_path/zlib_install/"
ZLIB_LIBRARY_install="$root_path/zlib_install/lib/"
OPENSSL_ROOT_install="$root_path/openssl_install/"
OPENSSL_LIBRARY_install="$root_path/openssl_install/lib64/"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}
# -DZLIB_LIBRARY= "$ZLIB_LIBRARY_install" \
# -DOPENSSL_SSL_LIBRARY= "$OPENSSL_SSL_LIBRARY_install" \
# -DZLIB_ROOT_DIR="${ZLIB_ROOT_install}" \

generate_build() {
  clear_path "$build_path"
  # https://github.com/libgit2/libgit2#advanced-usage
  # DUSE_BUNDLED_ZLIB 必须开启否则zlib链接错误
  # DCMAKE_FIND_ROOT_PATH 设置使用指定的ZLIB静态库
  cmake \
    -DUSE_BUNDLED_ZLIB=ON \
    -DUSE_SSH:BOOL=OFF \
    -DUSE_HTTPS:BOOL=OFF \
    -DUSE_THREADS:BOOL=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_FIND_ROOT_PATH=${ZLIB_ROOT_install} \
    -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_install} \
    -DOPENSSL_LIBRARIES=${OPENSSL_LIBRARY_install} \
    -DCMAKE_INSTALL_BINDIR="$install_path" \
    -DCMAKE_INSTALL_PREFIX="$install_path" \
    -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DLINK_WITH_STATIC_LIBRARIES:BOOL=ON \
    -S "$source_path" \
    -B "$build_path" 
}

build() {
  cmake --build "$build_path" -- -j$(nproc)
}

clear() {
  rm -rf "$build_path"
  rm -rf "$install_path"
}

test() {
  ctest --test-dir "$build_path" -V -- -j$(nproc)
}

install() {
  cmake --build "$build_path" --target install -- -j$(nproc)
}

main() {
  case $1 in
  -g)
    generate_build
  ;;
  -b)
    build
  ;;
  -i)
    install
  ;;
  -t)
    test
  ;;
  -c)
    clear
  ;;
  *)
    if [ -z "$1" ]; then
      generate_build && build && test && install
    else
      echo "不支持"
      exit 1
    fi
  ;;
  esac
}

main "$@" || exit 1