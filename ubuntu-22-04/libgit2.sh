#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../libgit2/"
build_path="$root_path/libgit2_build"
install_path="$root_path/libgit2_install"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}

generate_build() {
  clear_path "$build_path"
  # https://github.com/libgit2/libgit2#advanced-usage
  cmake -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_INSTALL_BINDIR="$install_path" \
        -DCMAKE_INSTALL_LIBDIR="$install_path" \
        -DCMAKE_INSTALL_INCLUDEDIR="$install_path" \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DUSE_THREADS:BOOL=OFF \
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