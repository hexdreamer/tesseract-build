#!/bin/zsh -f

scriptname=$0:A
parentdir=${scriptname%/build_autoconf.sh}
if ! source $parentdir/project_environment.sh -u; then
  echo "build_autoconf.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

local name='autoconf-2.69'

print "\n======== $name ========"

if {
  [ -f $ROOT/bin/autoconf ] &&
    version=$($ROOT/bin/autoconf --version) &&
    [[ $version =~ '2.69' ]]
}; then
  print "Skipped build, found $ROOT/bin/autoconf w/version 2.69"
  exit 0
fi

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="http://ftp.gnu.org/gnu/autoconf/$targz"

zsh $parentdir/_download.sh $name $url $targz
zsh $parentdir/_extract.sh $name $targz

# --  Config / Make / Install  ------------------------------------------------

xc mkdir -p $SOURCES/$name/x86
xc cd $SOURCES/$name/x86 || exit 1

print -n 'x86: '

print -n 'configuring... '
xl $name '2_config_x86' ../configure "--prefix=$ROOT" || exit 1
print -n 'done, '

print -n 'making... '
xl $name '3_clean_x86' make clean || exit 1
xl $name '3_make_x86' make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name '4_install_x86' make install || exit 1
print 'done.'
