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

export GEODIAG_ROOT=$(dirname $BASH_ARGV)
export GEODIAG_UTILS=$GEODIAG_ROOT/tools/utils
export PATH=$PATH:$GEODIAG_ROOT

# source other setup.sh scripts
for setup_script in $(find $GEODIAG_ROOT/scripts -name setup.sh); do
    source $setup_script
done

# command line completion
function _geodiag_()
{
    local prev_argv=${COMP_WORDS[COMP_CWORD-1]}
    local curr_argv=${COMP_WORDS[COMP_CWORD]}
    completed_words=""
    if [[ "${prev_argv##*/}" == "geodiag" ]]; then
        # complete subcommands
        case "$curr_argv" in
        "")
            completed_words="update"
            ;;
        esac
    fi
    COMPREPLY=($(compgen -W "$completed_words" -- $curr_argv))
}

complete -o default -F _geodiag_ geodiag
