#!/bin/bash
# ------------------------------------------------------------------------------
# Description:
#
#   This script is used to setup some environment variables or other things to
#   facilitate the running of GEODIAG.
#
# Authors:
#
#   Li Dong
# ------------------------------------------------------------------------------

export GEODIAG_ROOT=$(cd $(dirname $BASH_ARGV) && pwd)
export GEODIAG_PACKAGES=$GEODIAG_ROOT/packages
export GEODIAG_TOOLS=$GEODIAG_ROOT/tools
export PATH=$GEODIAG_ROOT:$PATH

source $GEODIAG_TOOLS/bash_utils.sh

# shared objects that can be loaded by NCL
if [[ -d $GEODIAG_TOOLS/shared ]]; then
    # only define NCL_DEF_LIB_DIR when shared directory is created
    export NCL_DEF_LIB_DIR=$GEODIAG_TOOLS/shared
fi

# source other setup.sh scripts
for package_setup in $(find $GEODIAG_PACKAGES -name setup.sh); do
    source $package_setup
done

# command line completion
function _geodiag_()
{
    local prev_argv=${COMP_WORDS[COMP_CWORD-1]}
    local curr_argv=${COMP_WORDS[COMP_CWORD]}
    completed_words=""
    case "${prev_argv##*/}" in
    "geodiag")
        completed_words="warmup list update help run"
        ;;
    "run")
        completed_words="mjo"
        ;;
    esac
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_argv))
}

complete -o default -F _geodiag_ geodiag
