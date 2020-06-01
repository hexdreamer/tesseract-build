#!/bin/zsh -f

# AUTOMAKE -- https://www.gnu.org/software/automake/

scriptname=$0:A
parentdir=${scriptname%/build_automake.sh}
if ! source $parentdir/project_environment.sh; then
  echo "build_automake.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  echo 'Deleting...'
  find $ROOT/bin \
    \( \
    -name 'aclocal*' -o \
    -name 'automake*' \
    \) \
    -print -exec rm -rf {} \; | sort
  exit 0
fi

local name='automake-1.16'

print "\n======== $name ========"

if {
  [ -f $ROOT/bin/automake ] &&
    version=$($ROOT/bin/automake --version) &&
    [[ $version =~ '1.16' ]]
}; then
  print "Skipped build, found $ROOT/bin/automake w/version 1.16"
  exit 0
fi

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="http://ftp.gnu.org/gnu/automake/$targz"

download $name $url $targz
extract $name $targz

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
