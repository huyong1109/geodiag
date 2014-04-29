#!/bin/bash

function prepare_model_data
{
    notice "Prepare cmor data for $(add_color mjo 'magenta bold') diagnostics."
    cmor_data_root=$1
    cmor_exp_id=$2
    cmor_data_list=$3
    internal_data_map=$4
    start_date=$5
    end_date=$6
    output_directory=$7
    # concatenate data
    cat_data "$cmor_data_root" "$cmor_exp_id" "$cmor_data_list" \
             "$internal_data_map" "$start_date" "$end_date" "$output_directory"
    # calculate daily anomalies
    calc_data_daily_anom "$output_directory"
    # run Lanczos filter
    run_lanczos_filter "$output_directory"
    # select seasons
    select_season "$output_directory"
}

function cat_data
{
    cmor_data_root=$1
    cmor_exp_id=$2
    cmor_data_list=$3
    internal_data_map=$4
    start_date=$5
    end_date=$6
    output_directory=$7
    # create a directory to store internal data files
    data_dir="$output_directory/data"
    if [[ ! -d "$data_dir" ]]; then
        mkdir -p "$data_dir"
        notice "Directory $data_dir is created."
    fi
    cat_var="$GEODIAG_TOOLS/dataset/cat_var.ncl"
    i=0
    for cmor_data in $cmor_data_list; do
        var_alias=""
        for data_map in $internal_data_map; do
            if [[ ${data_map/->*/} == $cmor_data ]]; then
                 var_alias=${data_map/*->/}
                 break
            fi
        done
        notice "Start to concatenate \"$cmor_data\"."
        cmor_data_dir="$cmor_data_root/day/atmos/$cmor_data/$exp_id"
        cmor_data_files=$(find $cmor_data_dir -name "*.nc")
        if [[ "$var_alias" != "" ]]; then
            mute_ncl $cat_var "'datasets=\"$(echo $cmor_data_files)\"'" \
                              "'var=\"$cmor_data\"'" \
                              "'var_alias=\"$var_alias\"'" \
                              "'output=\"$data_dir/$var_alias.nc\"'" \
                              "start_date=$start_date" \
                              "end_date=$end_date" \
                              "freq=1" &
        else
            mute_ncl $cat_var "'datasets=\"$(echo $cmor_data_files)\"'" \
                              "'var=\"$cmor_data\"'" \
                              "'date_range=\"$date_range\"'" \
                              "'output=\"$data_dir/$cmor_data.nc\"'" \
                              "start_date=$start_date" \
                              "end_date=$end_date" \
                              "freq=1" &
        fi
        cat_var_pids[$i]=$!
        i=$((i+1))
    done
    for (( i = 0; i < ${#cat_var_pids[@]}; ++i )); do
        notice "Waiting job ${cat_var_pids[$i]} ..."
        wait ${cat_var_pids[$i]}
    done
    # now we should have U850.nc, U200.nc, OLR.nc, PRECT.nc
    for file in $(echo "U850.nc U200.nc OLR.nc PRECT.nc"); do
        if [[ ! -f $data_dir/$file ]]; then
            report_error "Internal data \"$data_dir/$file\" should exist, but not!"
        fi
    done
}

function calc_data_daily_anom
{
    output_directory=$1
    calc_daily_anom="$GEODIAG_TOOLS/statistics/calc_daily_anom.ncl"
    data_dir="$output_directory/data"
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        data="$data_dir/$var.nc"
        notice "Start to calculate daily anomally of \"$var\"."
        mute_ncl $calc_daily_anom "'dataset=\"$data\"'" \
                                  "'var=\"$var\"'" \
                                  "'output=\"$data_dir/${var}.daily_anom.all.nc\"'" &
        calc_data_daily_anom_pids[$i]=$!
        i=$((i+1))
        sleep 1
    done
    for (( i = 0; i < ${#cat_var_pids[@]}; ++i )); do
        notice "Waiting job ${calc_data_daily_anom_pids[$i]} ..."
        wait ${calc_data_daily_anom_pids[$i]}
    done
}

function run_lanczos_filter
{
    output_directory=$1
    run_lanczos_filter="$GEODIAG_TOOLS/statistics/run_lanczos_filter.ncl"
    data_dir="$output_directory/data"
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        data="$data_dir/$var.daily_anom.all.nc"
        notice "Start to run Lanczos filter on daily anomaly of \"$var\"."
        mute_ncl $run_lanczos_filter "'dataset=\"$data\"'" \
                                     "'var=\"$var\"'" \
                                     "'pass=\"band\"'" \
                                     "time_step=1" \
                                     "start_time=20" \
                                     "end_time=100" \
                                     "num_wgt=201" \
                                     "'output=\"$data_dir/${var}.filtered.daily_anom.all.nc\"'" &
        run_lanczos_filter_pids[$i]=$!
        i=$((i+1))
        sleep 1
    done
    for (( i = 0; i < ${#run_lanczos_filter_pids[@]}; ++i )); do
        notice "Waiting job ${run_lanczos_filter_pids[$i]} ..."
        wait ${run_lanczos_filter_pids[$i]}
    done
}

function select_season
{
    output_directory=$1
    select_season="$GEODIAG_TOOLS/dataset/select_season.ncl"
    data_dir="$output_directory/data"
    for var in $(echo "U850 U200 OLR PRECT"); do
        # unfiltered
        data="$data_dir/${var}.daily_anom.all.nc"
        for season in $(echo "boreal_winter boreal_summer"); do
            notice "Start to extract season \"$season\" from \"$var\"."
            mute_ncl $select_season "'dataset=\"$data\"'" \
                                    "'var=\"$var\"'" \
                                    "'season=\"$season\"'" \
                                    "'output=\"$data_dir/${var}.daily_anom.$season.nc\"'"
        done
        # filtered
        data="$data_dir/${var}.filtered.daily_anom.all.nc"
        for season in $(echo "boreal_winter boreal_summer"); do
            notice "Start to extract season \"$season\" from filtered \"$var\"."
            mute_ncl $select_season "'dataset=\"$data\"'" \
                                    "'var=\"$var\"'" \
                                    "'season=\"$season\"'" \
                                    "'output=\"$data_dir/${var}.filtered.daily_anom.$season.nc\"'"
        done
    done
}

