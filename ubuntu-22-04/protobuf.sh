root_path="$(pwd)"
source_path="$root_path/../protobuf/"
build_path="$root_path/protobuf_build/"
install_path="$root_path/protobuf_install/"

google_install_path="$root_path/googletest_install/"
abseil_cpp_install_path="${root_path}/abseil-cpp_install/"


clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}

generate_build() {
  clear_path "$build_path"
  if [ -d "$google_install_path" -a -d "$abseil_cpp_install_path" ]; then
    cmake -DCMAKE_CXX_STANDARD=17 \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_PREFIX_PATH:PATH="${google_install_path};${abseil_cpp_install_path}" \
          -Dprotobuf_ABSL_PROVIDER=ON \
          -Dprotobuf_ABSL_PROVIDER=package \
          -Dprotobuf_BUILD_TESTS=ON \
          -Dprotobuf_USE_EXTERNAL_GTEST=ON \
          -S "$source_path" \
          -B "$build_path"
  else
    rm -rf "$build_path"
    echo "protobuf generate build faild"
    exit 1
  fi
}

build() {
  cmake --build "$build_path" --target all -- -j$(nproc)
}

install() {
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