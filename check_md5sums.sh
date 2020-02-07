#!/bin/bash -l

function show_help () {
cat <<HEREDOC
File:
    check_md5sums.sh

Version:
   7 feb 2020

By:
    Johan.Nylander\@nbis.se

Usage:
    ./check_md5sums.sh

Description:
    Check md5sums on any md5 files found in directory tree,
    starting in the current working directory.
    Files need to end in .md5 (case insensitive),
    or be named MD5SUMS or MD5SUM.

Options:
    -?, -h  -- show this help
    -v      -- be more verbose

HEREDOC
}

if ! hash md5sum 2>/dev/null ; then
  echo "Error: program md5sum is not found. Aborting"
  exit 1
fi

verbose=0
found=0

while getopts "h?v" opt; do
  case "$opt" in
  h|\?)
    show_help
    exit 0
    ;;
  v)  verbose=1
    ;;
  esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

dirs=($(find "$PWD" -type d))

for dir in "${dirs[@]}"; do
  cd "$dir"
  myarray=($(find ./ -maxdepth 1 -iname '*.md5' -or -iname 'MD5SUM' -or -iname 'MD5SUMS'))
  if [ ${#myarray[@]} -gt 0 ]; then
    found=1
    if [ "$verbose" -eq 1 ]; then
      echo "Checking ${#myarray[@]} md5-sum files in $PWD:"
      #echo ''
    fi
    for f in "${myarray[@]}" ; do
        md5sum -c $f
    done
    if [ "$verbose" -eq 1 ]; then
      echo ''
    fi
  fi
done
if [ "$found" -eq 0 ]; then
  echo "No md5 files found (look for MD5SUMS or .md5)"
fi
if [ "$verbose" -eq 1 ]; then
  echo 'Done with script' "$0"
fi

