root_path="$(pwd)"
source_path="$root_path/../fmt/"
build_path="$root_path/fmt_build/"
install_path="$root_path/fmt_install/"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1"/*
  fi
}

generate_build() {
  clear_path "$build_path"
  cmake -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
  -DCMAKE_INSTALL_PREFIX="$install_path" \
  -S "$source_path" \
  -B "$build_path"
}

build() {
  cmake --build "$build_path" -- -j$(nproc)
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