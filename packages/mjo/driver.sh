#!/bin/bash

MJO_ROOT=$GEODIAG_PACKAGES/mjo

source $MJO_ROOT/parse_config.sh
source $MJO_ROOT/prepare_data.sh
source $MJO_ROOT/level_1_diag.sh
source $MJO_ROOT/level_2_diag.sh
source $MJO_ROOT/supp_diag.sh

function mjo_help
{
    notice "$(add_color mjo 'magenta bold') diagnositic package usage:"
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
    ## prepare data
    if should_run "$diag_stages" "prepare_cmor_data"; then
        prepare_cmor_data "$cmor_data_root" "$cmor_exp_id" \
                          "$cmor_data_list" "$internal_data_map" \
                          "$start_date" "$end_date" "$output_directory"
    fi
    if [[ ! -d "$output_directory/figures" ]]; then
        mkdir "$output_directory/figures"
    fi
    # run level-1 diagnosis
    if should_run "$diag_stages" "run_level_1"; then
        run_level_1 "$output_directory"
    fi
    # run level-2 diagnosis
    if should_run "$diag_stages" "run_level_2"; then
        run_level_2 "$output_directory"
    fi
    # run supplemental diagnosis
    if should_run "$diag_stages" "run_supp"; then
        run_supp "$output_directory"
    fi
}

function mjo_config
{
    config_file="mjo.config"
    if [[ -f "$config_file" ]]; then
        report_warning "Configuation $(add_color $config_file 'bold') exists!"
        exit 0
    fi
    cat <<EOF > "$config_file"
cmor_data_root      =   
cmor_exp_id         =   
cmor_data_list      =   pr rlut ua200 ua850
internal_data_map   =   pr->PRECT rlut->OLR ua200->U200 ua850->U850
start_date          =   19790101
end_date            =   20081231
output_directory    =   ./result
diag_stages         =   all
EOF
    notice "Please fill in $(add_color $config_file 'bold')."
}
