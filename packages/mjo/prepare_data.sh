#!/bin/bash

function prepare_model_data
{
    notice "Prepare model data for $(add_color mjo 'magenta bold') diagnostics."
    model_data_root=$1
    # concatenate data
    model_data_pattern=$2
    model_data_files=$(find $model_data_root -name "$model_data_pattern")
    model_data_list=$3
    internal_data_map=$4
    output_directory=$5
    cat_data "$model_data_files" "$model_data_list" "$internal_data_map" \
             "$output_directory"
    # calculate daily anomalies
    calc_data_daily_anom "$output_directory"
    # run Lanczos filter
    run_lanczos_filter "$output_directory"
    # select seasons
    select_season "$output_directory"
}

function cat_data
{
    model_data_files=$1
    model_data_list=$2
    internal_data_map=$3
    output_directory=$4
    # create a directory to store internal data files
    data_dir="$output_directory/data"
    if [[ ! -d "$data_dir" ]]; then
        mkdir -p "$data_dir"
        notice "Directory $data_dir is created."
    fi
    cat_var="$GEODIAG_TOOLS/dataset/cat_var.ncl"
    i=0
    for model_data in $model_data_list; do
        var_alias=""
        for data_map in $internal_data_map; do
            if [[ ${data_map/->*/} == $model_data ]]; then
                 var_alias=${data_map/*->/}
                 break
            fi
        done
        notice "Start to concatenate \"$model_data\"."
        if [[ "$var_alias" != "" ]]; then
            mute_ncl $cat_var "'datasets=\"$(echo $model_data_files)\"'" \
                              "'var=\"$model_data\"'" \
                              "'var_alias=\"$var_alias\"'" \
                              "'output=\"$data_dir/$var_alias.nc\"'" \
                              "freq=1" &
        else
            mute_ncl $cat_var "'datasets=\"$(echo $model_data_files)\"'" \
                              "'var=\"$model_data\"'" \
                              "'output=\"$data_dir/$model_data.nc\"'" \
                              "freq=1" &
        fi
        cat_var_pids[$i]=$!
        i=$((i+1))
    done
    for (( i = 0; i < ${#cat_var_pids[@]}; ++i )); do
        notice "Waiting job ${cat_var_pids[$i]} ..."
        wait ${cat_var_pids[$i]}
    done
    # now we should have U850.nc, U200.nc and OLR.nc
    for file in $(echo "U850.nc U200.nc OLR.nc"); do
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
    for file in $(echo "U850.nc U200.nc OLR.nc"); do
        data="$data_dir/$file"
        var=$(basename $data .nc)
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
    for file in $(echo "U850.daily_anom.all.nc U200.daily_anom.all.nc OLR.daily_anom.all.nc"); do
        data="$data_dir/$file"
        var=$(basename $data .daily_anom.all.nc)
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
    for var in $(echo "U850 U200 OLR"); do
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

