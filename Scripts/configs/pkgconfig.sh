#!/bin/zsh -f

# PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/

export NAME='pkg-config-0.29.2'
export TARGZ="$NAME.tar.gz"
export URL="https://pkg-config.freedesktop.org/releases/$TARGZ"
export VER_COMMAND="$ROOT/bin/pkg-config --version"
export VER_PATTERN='0.29.2'
export TARGETS=('x86')

x86() {
    export CONFIG_FLAGS=(
        '--with-internal-glib'
    )
    export CONFIG_CMD='../configure'
}
