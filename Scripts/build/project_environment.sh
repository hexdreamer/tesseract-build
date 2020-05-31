#! /bin/zsh -f

# Relative to this running script named 'project_environment.sh'...
local SCRIPTNAME=$0:A
local -r BUILDDIR=${SCRIPTNAME%/project_environment.sh}
local -r SCRIPTSDIR=${BUILDDIR%/build}

# set paths one dir-level up from this directory named 'Scripts'
local -r PROJECTDIR=${SCRIPTSDIR%/Scripts}

local -r DOWNLOADS=$PROJECTDIR/Downloads
local -r LOGS=$PROJECTDIR/Logs
local -r ROOT=$PROJECTDIR/Root
local -r SOURCES=$PROJECTDIR/Sources

local -r MASTER_CMDS=$LOGS/commands.sh

local -r PATH=$ROOT/bin:$PATH

# call as `project_environment.sh -u` to also source the utilities
if [[ $1 == '-u' ]]; then
    if ! source $BUILDDIR/utility.sh ; then
        echo "project_environment.sh: error sourcing $BUILDDIR/utility.sh"
        exit 1
    fi
fi