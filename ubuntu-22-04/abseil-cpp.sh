#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../abseil-cpp/"
build_path="$root_path/abseil-cpp_build/"
install_path="$root_path/abseil-cpp_install/"

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
    -DABSL_PROPAGATE_CXX_STD=ON \
    -DABSL_BUILD_TESTING=ON \
    -DCMAKE_PREFIX_PATH:PATH="$google_install_path" \
    -DABSL_FIND_GOOGLETEST=ON \
    -DABSL_USE_EXTERNAL_GOOGLETEST=ON \
    -DCMAKE_INSTALL_PREFIX="$install_path" \
    -DABSL_ENABLE_INSTALL=ON \
    -S "$source_path" \
    -B "$build_path"
  else
    rm -rf "$build_path"
    echo "googletest 未安装"
    exit 1
  fi
}

build() {
  cmake --build "$build_path" -- -j$(nproc)
}

test() {
  ctest --test-dir "$build_path" -- -j$(nproc)
}

install() {
  clear_path "$install_path"

  cmake --build "$build_path" --target install  -- -j$(nproc)
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