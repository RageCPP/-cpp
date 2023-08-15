#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../grpc/"
build_path="$root_path/grpc_build/"
install_path="$root_path/grpc_install/"

zlib_install_path="$root_path/zlib_install/"
re2_install_path="$root_path/re2_install/"
protobuf_install_path="$root_path/protobuf_install/"
abseil_cpp_install_path="$root_path/abseil-cpp_install/"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}

generate_build() {
  clear_path "$build_path"
  
  cmake -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_CARES_PROVIDER=module \
  -DgRPC_SSL_PROVIDER=module \
  -DgRPC_ZLIB_PROVIDER=package \
  -DgRPC_PROTOBUF_PROVIDER=package \
  -DgRPC_RE2_PROVIDER=package  \
  -DgRPC_ABSL_PROVIDER=package \
  -DgRPC_INSTALL=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="${zlib_install_path};${protobuf_install_path};${re2_install_path};${abseil_cpp_install_path}" \
  -S "$source_path" \
  -B "$build_path"
 
}

build() {
  cmake --build "$build_path"  -- -j$(nproc)
}

install() {
  clear_path "$install_path"

  cmake --install "$build_path" --prefix="$install_path"
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
  -i)
    install
  ;;
  -c)
    clear
  ;;
  *)
    if [ -z "$1" ]; then
      generate_build && build && install
    else
      echo "不支持"
      exit 1
    fi
  ;;
  esac
}

main "$@" || exit 1
