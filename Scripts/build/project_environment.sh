#!/bin/zsh -f
# shellcheck disable=SC2034

# Relative to this running script named 'project_environment.sh'...
SCRIPTNAME=$0:A
readonly BUILDDIR=${SCRIPTNAME%/project_environment.sh}
readonly SCRIPTSDIR=${BUILDDIR%/build}

# set paths one dir-level up from this directory named 'Scripts'
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
