#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../benchmark/"
build_path="$root_path/benchmark_build/"
install_path="$root_path/benchmark_install/"

google_install_path="$root_path/googletest_install/"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1"/*
  fi
}

generate_build() {
  clear_path "$build_path"

  # TODO:
  # 未判断 google_install_path 是否有效
  if [ -d "$google_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DBENCHMARK_USE_BUNDLED_GTEST:BOOL=OFF \
    -DGTEST_ROOT:PATH="$google_install_path" \
    -S "$source_path" \
    -B "$build_path"
  else
    rm -rf "$build_path"
    echo "googletest 未安装"
    exit 1
  fi
}

build() {
  cmake --build "$build_path" --config Release -- -j$(nproc)
}

test() {
  ctest --test-dir "$build_path" --build-config Release -- -j$(nproc)
}

install() {
  clear_path "$install_path"

  cmake --build "$build_path" --config Release --target install  -- -j$(nproc)
}

clear() {
  rm -rf "$build_path"
  rm -rf "$install_path"
}

main() {
  case $1 in
  -g)
    generate_build
  ;;
  -b)
    build
  ;;
  -t)
    test
  ;;
  -i)
    install
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