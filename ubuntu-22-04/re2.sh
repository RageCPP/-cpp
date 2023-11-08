#!/bin/sh

root_path="$(pwd)"
clear_sh_path="$root_path/common_sh/clear.sh"

source_path="$root_path/../re2/"

build_path="$root_path/re2_build/"
install_path="$root_path/re2_install/"

static_build_path="$build_path/static/"
static_install_path="$install_path/static/"

share_build_path="$build_path/share/"
share_install_path="$install_path/share/"

google_install_path="$root_path/googletest_install/"
benchmark_install_path="$root_path/benchmark_install/"

static_abseil_cpp_install_path="${root_path}/abseil-cpp_install/static/"
share_abseil_cpp_install_path="${root_path}/abseil-cpp_install/share/"


static_generate_build() {
  eval "sh ${clear_sh_path} ${static_build_path}"

  # TODO:
  # 未判断 google_install_path 是否有效
  # -- Found the following ICU libraries:
  # --   uc (required): /usr/lib/x86_64-linux-gnu/libicuuc.so
  # -- Found ICU: /usr/include (found version "70.1")
  if [ -d "$google_install_path" -a -d "$benchmark_install_path" -a -d "$static_abseil_cpp_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DRE2_USE_ICU:BOOL=ON \
    -DRE2_BUILD_TESTING:BOOL=ON \
    -DCMAKE_PREFIX_PATH:PATH="${google_install_path};${benchmark_install_path};${static_abseil_cpp_install_path}" \
    -DCMAKE_INSTALL_PREFIX="$static_install_path" \
    -S "$source_path" \
    -B "$static_build_path"
  else
    rm -rf "$static_build_path"
    echo "googletest 未安装"
    echo "benchmark 未安装"
    echo "abseil 未安装"
    exit 1
  fi
}

share_generate_build() {
  eval "sh ${clear_sh_path} ${share_build_path}"
  if [ -d "$share_abseil_cpp_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DRE2_USE_ICU:BOOL=ON \
    -DRE2_BUILD_TESTING:BOOL=OFF \
    -DCMAKE_PREFIX_PATH:PATH="${share_abseil_cpp_install_path}" \
    -DCMAKE_INSTALL_PREFIX="$share_install_path" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -S "$source_path" \
    -B "$share_build_path"
  else
    rm -rf "$sahre_build_path"
    echo "googletest 未安装"
    echo "benchmark 未安装"
    echo "abseil 未安装"
    exit 1
  fi
}

static_build() {
  cmake --build "$static_build_path" --config Release -- -j$(nproc)
}

static_test() {
  ctest --test-dir "$static_build_path" --build-config Release -- -j$(nproc)
}

static_install() {
  clear_path "$static_install_path"

  cmake --build "$static_build_path" --config Release --target install  -- -j$(nproc)
}


share_build() {
  cmake --build "$share_build_path" --config Release -- -j$(nproc)
}

share_install() {
  clear_path "$share_install_path"

  cmake --build "$share_build_path" --config Release --target install  -- -j$(nproc)
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
