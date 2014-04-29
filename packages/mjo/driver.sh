#!/bin/bash

MJO_ROOT=$GEODIAG_PACKAGES/mjo

source $MJO_ROOT/parse_config.sh
source $MJO_ROOT/prepare_data.sh
source $MJO_ROOT/level_1_diag.sh
source $MJO_ROOT/level_2_diag.sh
source $MJO_ROOT/supp_diag.sh

function mjo_help
{
    notice "$(add_color mjo 'magenta bold') diagnosis package usage:"
    echo
    echo -e "\tgeodiag $(add_color run bold) $(add_color mjo 'magenta bold') <config file>"
    echo
}

function mjo_run
{
    report_warning "MJO diagnosis package is under construction!"
    if (( $# == 0 )); then
        mjo_help
        report_error "Wrong usage!"
    fi
    # parse configuration
    parse_config $1
    # prepare data
    prepare_model_data "$cmor_data_root" "$cmor_exp_id" \
                       "$cmor_data_list" "$internal_data_map" \
                       "$start_date" "$end_date" "$output_directory"
    if [[ ! -d "$output_directory/figures" ]]; then
        mkdir "$output_directory/figures"
    fi
    # run level-1 diagnosis
    run_level_1 "$output_directory"
    ## run level-2 diagnosis
    #run_level_2
    ## run supplemental diagnosis
    #run_supp
}
