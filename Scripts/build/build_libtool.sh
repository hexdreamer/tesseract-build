#!/bin/zsh -f

# LIBTOOL -- https://www.gnu.org/software/libtool/

scriptname=$0:A
parentdir=${scriptname%/build_libtool.sh}
if ! source $parentdir/project_environment.sh -u; then
  echo "build_libtool.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

local name='libtool-2.4.6'

print "\n======== $name ========"

if {
  [ -f $ROOT/bin/libtool ] &&
    version=$($ROOT/bin/libtool --version) &&
    [[ $version =~ '2.4.6' ]]
}; then
  echo "Skipped build, found $ROOT/bin/libtool w/version 2.4.6"
  exit 0
fi

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="http://ftp.gnu.org/gnu/libtool/$targz"

zsh $parentdir/_download.sh $name $url $targz
zsh $parentdir/_extract.sh $name $targz

# --  Config / Make / Install  ------------------------------------------------

xc mkdir -p $SOURCES/$name/x86
xc cd $SOURCES/$name/x86 || exit 1

print -n 'x86: '

print -n 'configuring... '
xl $name '2_config_x86' ../configure --prefix=$ROOT || exit 1
print -n 'done, '

print -n 'making... '
xl $name '3_clean_x86' make clean || exit 1
xl $name '3_make_x86' make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name '4_install_x86' make install || exit 1
print 'done.'
