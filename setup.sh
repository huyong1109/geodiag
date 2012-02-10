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
