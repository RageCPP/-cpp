#!/bin/sh

root_path="$(pwd)"
clear_sh_path="$root_path/common_sh/clear.sh"

source_path="$root_path/../CLI11/"
build_path="$root_path/CLI11_build"
install_path="$root_path/CLI11_install/"

boost_install_path="$root_path/boost_install/"

generate_build() {
  eval "sh ${clear_sh_path} ${build_path}"
  if [ -d "$boost_install_path" ]; then
    cmake -DBOOST_ROOT="$boost_install_path" \
      -DCLI11_BOOST:BOOL=ON \
      -B "$build_path" \
      -S "$source_path"
  else
    rm -rf "$build_path"
    echo "boost 未安装 需要boost test"
    exit 1
  fi
}

build() {
  cmake --build "$build_path"  -- -j$(nproc)
}

install() {
  eval "sh ${clear_sh_path} ${install_path}"

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
