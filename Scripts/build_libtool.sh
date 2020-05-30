#!/bin/zsh -f

# LIBTOOL -- https://www.gnu.org/software/libtool/

scriptname=$0:A
parentdir=${scriptname%/build_libtool.sh}
if ! source $parentdir/project_environment.sh; then
  echo "build_libtool.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if ! source $SCRIPTSDIR/utility.sh; then
  echo "build_libtool.sh: error sourcing $SCRIPTSDIR/utility.sh"
  exit 1
fi

local name='libtool-2.4.6'
print "\n======== $name ========"

# Uncomment to turn on skip-if-already-installed
#
if [ -f $SOURCES/$name/x86_64/Makefile ]; then
  filepath=$(find $ROOT/bin \( -name 'libtool' -a -newer $SOURCES/$name/x86_64/Makefile \))
  if [[ $filepath == $ROOT/bin/libtool ]]; then
    version_str=$($ROOT/bin/libtool --version 2>&1)
    if [[ $version_str == *'2.4.6'* ]]; then
      echo "Skipped all steps, found $ROOT/bin/libtool with version 2.4.6"
      exit 0
    fi
  fi
fi

# Being respectful of hosts and their bandwidth
targz=$name.tar.gz
if [ -e $DOWNLOADS/$targz ]; then
  echo "Skipped download, using cached $targz in Downloads."
else
  print -n 'Downloading...'
  url="http://ftp.gnu.org/gnu/libtool/$targz"
  xl $name '0_curl' curl -L -f $url --output $DOWNLOADS/$targz
  print ' done.'
fi

# Being respectful of any hacking/work done to get a package to build
if [ -d $SOURCES/$name ]; then
  echo "Skipped extract of TGZ, using cached $name in Sources."
else
  print -n 'Extracting...'
  xl $name '1_untar' tar -zxf $DOWNLOADS/$targz --directory $SOURCES
  print ' done.'
fi

xc mkdir -p $SOURCES/$name/x86_64
xc cd $SOURCES/$name/x86_64

print -n 'x86_64: '

print -n 'configuring... '
export CFLAGS='--target=x86_64-apple-darwin'
xl $name '2_config_x86_64' ../configure --prefix=$ROOT || exit 1
print -n 'done, '

print -n 'making... '
xl $name '3_clean_x86_64' make clean || exit 1
xl $name '3_make_x86_64' make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name '4_install_x86_64' make install || exit 1
print 'done.'
