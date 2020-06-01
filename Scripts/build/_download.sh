#! /bin/zsh

name=$1
url=$2
targz=$3

scriptname=$0:A
parentdir=${scriptname%/_download.sh}
if ! source $parentdir/project_environment.sh -u; then
  echo "_download.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [ -e $DOWNLOADS/$targz ]; then
  echo "Skipped download, found $DOWNLOADS/$targz"
  return 0
fi

print -n 'Downloading...'
xl $name '0_curl' curl -L -f $url --output $DOWNLOADS/$targz
print ' done.'
