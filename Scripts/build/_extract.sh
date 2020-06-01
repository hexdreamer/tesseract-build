#! /bin/zsh -f

name=$1
targz=$2

if [[ -n $3 ]]; then
    dirname=$3
else
    dirname=$name
fi

scriptname=$0:A
parentdir=${scriptname%/_extract.sh}
source $parentdir/project_environment.sh -u || { echo Error sourcing $parentdir/project_environment.sh; exit 1 }

if [ -d $SOURCES/$dirname ]; then
    echo "Skipped extract of TGZ, found $SOURCES/$dirname"
    return 0
fi

print -n 'Extracting...'
xl $name '1_untar' tar -zxf $DOWNLOADS/$targz --directory $SOURCES
print ' done.'
