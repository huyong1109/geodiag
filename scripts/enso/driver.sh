#!/bin/bash

source $GEODIAG_ROOT/scripts/utils/geodiag_cmd_utils.sh

ENSO_ROOT=$GEODIAG_ROOT/scripts/enso

function enso_driver
{
    notice "Input the data file."
    read -e -p " > " file_name
    check_file_exist ${file_name}
    notice "Input the start year."
    read -p " > " start_year
    notice "Input the end year."
    read -p " > " end_year
    ncl $ENSO_ROOT/nino34_wavelet.ncl \
        start_year=${start_year} \
        end_year=${end_year} \
        file_name=\"${file_name}\"
}
