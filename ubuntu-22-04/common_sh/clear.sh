clear_path() {
  if [ ! -d "$1" ]; then
    eval "mkdir ${1}"
  else
    eval "rm -rf ${1}/*"
  fi
}

main() {
  clear_path "$1"
}

main "$@" || exit 1
