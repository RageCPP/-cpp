#!/bin/sh

root_path="$(pwd)"
clear_sh_path="$root_path/common_sh/clear.sh"

source_path="$root_path/../protobuf/"

build_path="$root_path/protobuf_build/"
install_path="$root_path/protobuf_install/"

static_build_path="$build_path/static/"
static_install_path="$install_path/static/"

share_build_path="$build_path/share/"
share_install_path="$install_path/share/"

google_install_path="$root_path/googletest_install/"

static_abseil_cpp_install_path="${root_path}/abseil-cpp_install/static/"
share_abseil_cpp_install_path="${root_path}/abseil-cpp_install/share/"

static_generate_build() {
  eval "sh ${clear_sh_path} ${static_build_path}"

  if [ -d "$google_install_path" -a -d "$static_abseil_cpp_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_PREFIX_PATH:PATH="${google_install_path};${static_abseil_cpp_install_path}" \
          -Dprotobuf_ABSL_PROVIDER=ON \
          -Dprotobuf_ABSL_PROVIDER=package \
          -Dprotobuf_BUILD_TESTS=ON \
          -Dprotobuf_USE_EXTERNAL_GTEST=ON \
          -S "$source_path" \
          -B "$static_build_path"
  else
    rm -rf "$static_build_path"
    echo "protobuf generate build faild"
    exit 1
  fi
}

share_generate_build() {
  eval "sh ${clear_sh_path} ${share_build_path}"

  if [ -d "$share_abseil_cpp_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_PREFIX_PATH:PATH="${share_abseil_cpp_install_path}" \
          -Dprotobuf_ABSL_PROVIDER=ON \
          -Dprotobuf_ABSL_PROVIDER=package \
          -Dprotobuf_BUILD_TESTS=OFF \
          -Dprotobuf_USE_EXTERNAL_GTEST=OFF \
          -Dprotobuf_BUILD_SHARED_LIBS=ON \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -S "$source_path" \
          -B "$share_build_path"
  else
    rm -rf "$share_build_path"
    echo "protobuf generate build faild"
    exit 1
  fi
}

static_build() {
  cmake --build "$static_build_path" --target all -- -j$(nproc)
}

share_build() {
  cmake --build "$share_build_path" --target all -- -j$(nproc)
}

static_install() {
  cmake --install "$static_build_path" --prefix="$static_install_path"
}

share_install() {
  cmake --install "$share_build_path" --prefix="$share_install_path"
}



static() {
  case $1 in
    -g)
      static_generate_build
      ;;
    -b)
      static_build
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

clear() {
  rm -rf "$build_path"
  rm -rf "$install_path"
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
