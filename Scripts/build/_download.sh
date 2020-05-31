#! /bin/zsh

name=$1
url=$2
targz=$3

scriptname=$0:A
parentdir=${scriptname%/_download.sh}
source $parentdir/project_environment.sh -u || { echo Error sourcing $parentdir/project_environment.sh; exit 1 }

if [ -e $DOWNLOADS/$targz ]; then
  echo "Skipped download, using cached $targz in Downloads."
  return 0
fi

print -n 'Downloading...'
xl $name '0_curl' curl -L -f $url --output $DOWNLOADS/$targz
print ' done.'
