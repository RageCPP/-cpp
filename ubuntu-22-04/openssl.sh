#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../openssl"
build_path="$root_path/openssl_build/"
install_path="$root_path/openssl_install/"

zlib_install_lib="$root_path/zlib_install/lib"
zlib_install_include="$root_path/zlib_install/include"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1"/*
  fi
}

generate_install() {
  clear_path "$build_path"
  "${source_path}"/Configure zlib --with-zlib-lib="${zlib_install_lib}" --with-zlib-include="${zlib_install_include}" --prefix="${install_path}" no-shared -static
}

install() {
  
}

clear() {
  rm -rf "$build_path"
  rm -rf "$install_path"
}


main() {
  case $1 in
  -g)
    generate_install
  ;;
  -i)
    install
  ;;
  -c)
    clear
  ;;
  *)
    if [ -z "$1" ]; then
      install
    else
      echo "不支持"
      exit 1
    fi
  ;;
  esac
}

main "$@" || exit 1