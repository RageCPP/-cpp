clear_path() {
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
    rm -rf "$1/*"
  fi
}

main() {
  clear_path "$1"
}

main "$@" || exit 1
