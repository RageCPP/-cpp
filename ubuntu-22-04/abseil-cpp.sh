#!/bin/bash

root_path="$(pwd)"
clear_sh_path="$root_path/common_sh/clear.sh"

source_path="$root_path/../abseil-cpp/"

build_path="$root_path/abseil-cpp_build/"
install_path="$root_path/abseil-cpp_install/"

static_build_path="$build_path/static/"
static_install_path="$install_path/static/"

share_build_path="$build_path/share/"
share_install_path="$install_path/share/"

google_install_path="$root_path/googletest_install/"

static_generate_build() {
  eval "sh ${clear_sh_path} ${static_build_path}"

  # TODO:
  # 未判断 google_install_path 是否有效
  if [ -d "$google_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DABSL_PROPAGATE_CXX_STD=OFF \
    -DABSL_BUILD_TESTING=ON \
    -DCMAKE_PREFIX_PATH:PATH="$google_install_path" \
    -DABSL_FIND_GOOGLETEST=ON \
    -DABSL_USE_EXTERNAL_GOOGLETEST=ON \
    -DCMAKE_INSTALL_PREFIX="$static_install_path" \
    -DABSL_ENABLE_INSTALL=ON \
    -S "$source_path" \
    -B "$static_build_path"
  else
    rm -rf "$static_build_path"
    echo "googletest 未安装"
    exit 1
  fi
}
share_generate_build() {
    eval "sh ${clear_sh_path} ${share_build_path}"

  # TODO:
  # 未判断 google_install_path 是否有效
  if [ -d "$google_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DABSL_PROPAGATE_CXX_STD=OFF \
    -DABSL_BUILD_TESTING=OFF \
    -DCMAKE_PREFIX_PATH:PATH="$google_install_path" \
    -DABSL_FIND_GOOGLETEST=OFF \
    -DABSL_USE_EXTERNAL_GOOGLETEST=OFF \
    -DCMAKE_INSTALL_PREFIX="$share_install_path" \
    -DABSL_ENABLE_INSTALL=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -S "$source_path" \
    -B "$share_build_path"
  else
    rm -rf "$share_build_path"
    echo "googletest 未安装"
    exit 1
  fi
}

static_build() {
  cmake --build "$static_build_path" -- -j$(nproc)
}

share_build() {
  cmake --build "$share_build_path" -- -j$(nproc)
}

static_test() {
  ctest --test-dir "$static_build_path" -- -j$(nproc)
}

share_test() {
  ctest --test-dir "$share_build_path" -- -j$(nproc)
}

static_install() {
  eval "${clear_sh_path} ${static_install_path}"

  cmake --build "$static_build_path" --target install  -- -j$(nproc)
}

share_install() {
  eval "${clear_sh_path} ${share_install_path}"

  cmake --build "$share_build_path" --target install  -- -j$(nproc)
}

clear() {
  rm -rf "$build_path"
  rm -rf "$install_path"
}


static() {
  case $1 in
    -g)
      static_generate_build
      ;;
    -b)
      static_build
      ;;
    -t)
      static_test
      ;;
    -i)
      static_install
      ;;
    *)
      echo "不支持"
      ;;
  esac
}

share() {
  case $1 in
    -g)
      share_generate_build
      ;;
    -b)
      share_build
      ;;
    -t)
      share_test
      ;;
    -i)
      share_install
      ;;
    *)
      echo "不支持"
      ;;
  esac
}

main() {
  case $1 in
    clear | static | share)
      $1 $2
    ;;
  *)
    echo "unknown command: $1"
    exit 1;
    ;;
  esac
}

main "$@" || exit 1
