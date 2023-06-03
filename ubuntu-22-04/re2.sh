#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../re2/"
build_path="$root_path/re2_build/"
install_path="$root_path/re2 _install/"

google_install_path="$root_path/googletest_install/"
benchmark_install_path="$root_path/benchmark_install/"
abseil_cpp_install_path="$root_path/abseil-cpp_install"

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
  # -- Found the following ICU libraries:
  # --   uc (required): /usr/lib/x86_64-linux-gnu/libicuuc.so
  # -- Found ICU: /usr/include (found version "70.1")
  if [ -d "$google_install_path" -a -d "$benchmark_install_path" -a -d "$abseil_cpp_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DRE2_USE_ICU:BOOL=ON \
    -DRE2_BUILD_TESTING:BOOL=ON \
    -DCMAKE_PREFIX_PATH:PATH="${google_install_path};${benchmark_install_path};${abseil_cpp_install_path}" \
    -DCMAKE_INSTALL_PREFIX="$install_path" \
    -S "$source_path" \
    -B "$build_path"
  else
    rm -rf "$build_path"
    echo "googletest 未安装"
    echo "benchmark 未安装"
    echo "abseil 未安装"
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