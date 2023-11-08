#!/bin/sh

# 修改 grpc 的 CMakeLists.txt
# if (UNIX AND BUILD_SHARED_LIBS)
#  set_target_properties(grpc PROPERTIES
#    LINK_FLAGS "-Wl,-rpath,\"\$ORIGIN\""
#  )
# endif()

root_path="$(pwd)"
clear_sh_path="$root_path/common_sh/clear.sh"

source_path="$root_path/../grpc/"
build_path="$root_path/grpc_build"
install_path="$root_path/grpc_install"

static_build_path="$build_path/static/"
static_install_path="$install_path/static/"

share_build_path="$build_path/share/"
share_install_path="$install_path/share/"

static_re2_install_path="$root_path/re2_install/static/"
share_re2_install_path="$root_path/re2_install/share/"

static_protobuf_install_path="$root_path/protobuf_install/static/"
share_protobuf_install_path="$root_path/protobuf_install/share/"

static_abseil_cpp_install_path="$root_path/abseil-cpp_install/static/"
share_abseil_cpp_install_path="$root_path/abseil-cpp_install/share/"

zlib_install_path="$root_patdh/zlib_install/"
# openssl_install_path="$root_path/openssl_install/"
openssl_install_path="/usr/lib/x86_64-linux-gnu/"

static_generate_build() {
  eval "sh ${clear_sh_path} ${static_build_path}"
  
  cmake -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_CARES_PROVIDER=module \
  -DgRPC_SSL_PROVIDER=package \
  -DgRPC_ZLIB_PROVIDER=package \
  -DgRPC_PROTOBUF_PROVIDER=package \
  -DgRPC_RE2_PROVIDER=package  \
  -DgRPC_ABSL_PROVIDER=package \
  -DgRPC_INSTALL=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="${zlib_install_path};${static_protobuf_install_path};${static_re2_install_path};${static_abseil_cpp_install_path};${openssl_install_path}" \
  -S "$source_path" \
  -B "$static_build_path"
}

# if (UNIX AND BUILD_SHARED_LIBS)
#   set_target_properties(grpc PROPERTIES
#   LINK_FLAGS "-Wl,-rpath,\"\$ORIGIN\""
# )
# endif()

share_generate_build() {
  clear_path "$share_build_path"

  cmake -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_CARES_PROVIDER=module \
  -DgRPC_SSL_PROVIDER=package \
  -DgRPC_ZLIB_PROVIDER=package \
  -DgRPC_PROTOBUF_PROVIDER=package \
  -DgRPC_RE2_PROVIDER=package  \
  -DgRPC_ABSL_PROVIDER=package \
  -DgRPC_INSTALL=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="${zlib_install_path};${share_protobuf_install_path};${share_re2_install_path};${share_abseil_cpp_install_path};${openssl_install_path}" \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -S "$source_path" \
  -B "$share_build_path"
}

static_build() {
  cmake --build "$static_build_path"  -- -j$(nproc)
}

static_install() {
  clear_path "$static_install_path"

  cmake --install "$static_build_path" --prefix="$static_install_path"
}

share_build() {
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/ragecpp/hey-cpp/ubuntu-22-04/protobuf_install/share/lib:/home/ragecpp/hey-cpp/ubuntu-22-04/grpc_install/share/lib";
  cmake --build "$share_build_path"  -- -j$(nproc)
}

share_install() {
  clear_path "$share_install_path"

  cmake --install "$share_build_path" --prefix="$share_install_path"
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
