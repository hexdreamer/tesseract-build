#!/bin/zsh -f

# Convert all config `export VARNAME=...` statements to `unset VARNAME`
# grep -h export *.sh | \
#     grep -v '#' | \
#     awk -F'=' '{print $1}' | \
#     sed -e 's/^[[:space:]]*//' | \
#     sort -u | \
#     sed 's/export/unset/' | \
#     less

unset ARCH
unset CC
unset CFLAGS
unset CONFIG_CMD
unset CONFIG_FLAGS
unset CPPFLAGS
unset CXX
unset CXXFLAGS
unset CXX_FOR_BUILD
unset DIR_NAME
unset IOS_TARGETS
unset LDFLAGS
unset LDFLAGS_ARR
unset LIBLEPT_HEADERSDIR
unset LIBNAME
unset LIBS
unset MACOS_TARGETS
unset NAME
unset PKG_CONFIG_PATH
unset PLATFORM
unset PLATFORM_OS
unset PLATFORM_VERSION
unset PRECONFIG
unset SDKROOT
unset TARGET
unset TARGETS
unset TARGZ
unset URL
unset VER_COMMAND
unset VER_PATTERN
