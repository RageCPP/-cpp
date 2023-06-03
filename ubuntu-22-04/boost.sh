#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../boost/"
build_path="$root_path/../ubuntu-22-04/boost_build/"
install_path="$root_path/../ubuntu-22-04/boost_install/"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}


download() {
  clear_path "$source_path"
  if [ -f "/tmp/boost_1_82_0.tar.gz" ]; then
    rm -rf "/tmp/boost_1_82_0.tar.gz"
  fi
  curl -L https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz -o "/tmp/boost_1_82_0.tar.gz"
  tar -xvzf "/tmp/boost_1_82_0.tar.gz" -C "$source_path" --strip-components 1
  rm -rf "/tmp/boost_1_82_0.tar.gz"
}

install() {
  b2 \
    install \
    link=static \
    toolset=gcc \
    cxxstd=17 \
    staging-prefix="$install_path" \
    --build-dir="$build_path" \
    --prefix="$install_path"
}

clear() {
  rm -rf "$build_path"
  rm -rf "$install_path"
}

main() {
  case $1 in
  -d)
    download
  ;;
  -i)
    install
  ;;
  -c)
    clear
  ;;
  *)
    echo "$root_path"
  ;;
  esac
}

main "$@" || exit 1