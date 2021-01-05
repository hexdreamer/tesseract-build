#!/bin/zsh -f

# ZLIB --

scriptpath=$0:A
parentdir=${scriptpath%/*}
scriptname=${scriptpath##*/}

if ! source $parentdir/project_environment.sh; then
  echo "build_zlib.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  deleted=$(
    find $ROOT \
      \( -name '*libz*' -o -name '*zlib*' \) \
      -prune -print -exec rm -rf {} \;
  )
  if [[ -n $deleted ]]; then
    echo "$scriptname: deleted:"
    echo $deleted
  else
    echo "$scriptname: clean"
  fi
  exit 0
fi

name='zlib-1.2.11'

print "\n======== $name ========"

if [ -f $ROOT/lib/libz.a ]; then
  print "Skipped build, found $ROOT/lib/libz.a"
  exit 0
fi

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="https://sourceforge.net/projects/libpng/files/zlib/1.2.11/$targz/download"

download $name $url $targz
extract $name $targz

# --  Config / Make / Install  ------------------------------------------------

xc mkdir -p $SOURCES/$name/arm64
xc cd $SOURCES/$name/arm64 || exit 1

print -n 'arm64: '

print -n 'configuring... '
export CFLAGS="--target=arm-apple-darwin64"
xl $name '2_config_arm64' ../configure "--prefix=$ROOT" || exit 1
print -n 'done, '

print -n 'making... '
xl $name '3_clean_arm64' make clean || exit 1
xl $name '3_make_arm64' make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name '4_install_arm64' make install || exit 1
print 'done.'

xc mkdir -p $SOURCES/$name/x86_64
xc cd $SOURCES/$name/x86_64 || exit 1

print -n 'x86_64: '

print -n 'configuring... '
export CFLAGS="--target=x86_64_64-apple-darwin"
xl $name '2_config_x86_64' ../configure "--prefix=$ROOT" || exit 1
print -n 'done, '

print -n 'making... '
xl $name '3_clean_x86_64' make clean || exit 1
xl $name '3_make_x86_64' make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name '4_install_x86_64' make install || exit 1
print 'done.'
