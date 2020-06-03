#!/bin/zsh -f
# shellcheck disable=SC2034

# Relative to this running script named 'project_environment.sh'...
SCRIPTNAME=$0:A
readonly BUILDDIR=${SCRIPTNAME%/project_environment.sh}

# Scripts is one dir up
readonly SCRIPTSDIR=${BUILDDIR%/build}

# And the root of the project is one dir above scripts
readonly PROJECTDIR=${SCRIPTSDIR%/Scripts}

readonly DOWNLOADS=$PROJECTDIR/Downloads
readonly LOGS=$PROJECTDIR/Logs
readonly ROOT=$PROJECTDIR/Root
readonly SOURCES=$PROJECTDIR/Sources

readonly MASTER_CMDS=$LOGS/commands.sh

readonly PATH=$ROOT/bin:$PATH

if ! source $BUILDDIR/utility.sh; then
  echo "project_environment.sh: error sourcing $BUILDDIR/utility.sh"
  exit 1
fi
