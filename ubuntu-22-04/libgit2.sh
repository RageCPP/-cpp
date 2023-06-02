#!/bin/sh

root_path="$(pwd)"
source_path="$root_path/../libgit2/"
build_path="$root_path/libgit2_build"
install_path="$root_path/libgit2_install"

clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}

generate_build() {
  clear_path "$build_path"
  
}
