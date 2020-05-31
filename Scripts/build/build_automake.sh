#!/bin/zsh -f

# AUTOMAKE -- https://www.gnu.org/software/automake/

scriptname=$0:A
parentdir=${scriptname%/build_automake.sh}
if ! source $parentdir/project_environment.sh; then
    echo "build_automake.sh: error sourcing $parentdir/project_environment.sh"
    exit 1
fi

if ! source $SCRIPTSDIR/utility.sh; then
    echo "build_automake.sh: error sourcing $SCRIPTSDIR/utility.sh"
    exit 1
fi

local name='automake-1.16'

print "\n======== $name ========"

# Being respectful of hosts and their bandwidth
targz=$name.tar.gz
if [ -e $DOWNLOADS/$targz ]; then
    echo "Skipped download, using cached $targz in Downloads."
else
    print -n 'Downloading...'
    url="http://ftp.gnu.org/gnu/automake/$targz"
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
xl $name '2_config_x86_64' ../configure "--prefix=$ROOT" || exit 1
print -n 'done, '

print -n 'making... '
xl $name '3_clean_x86_64' make clean || exit 1
xl $name '3_make_x86_64' make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name '4_install_x86_64' make install || exit 1
print 'done.'
