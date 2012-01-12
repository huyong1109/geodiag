#!/bin/bash

ENSO_ROOT=$GEODIAG_ROOT/scripts/enso

function enso_driver
{
    echo "[Notice]: Input the data file."
    read -e -p " > " file_name
    echo "[Notice]: Input the start year."
    read -p " > " start_year
    echo "[Notice]: Input the end year."
    read -p " > " end_year
    ncl $ENSO_ROOT/nino34_wavelet.ncl \
        start_date=${start_year}01 \
        end_date=${end_year}12 \
        file_name=\"${file_name}\"
}
