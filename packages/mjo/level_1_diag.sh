#!/bin/bash

function run_level_1
{
    notice "Run $(add_color level-1 'red bold') $(add_color mjo 'magenta bold') diagnostics."
    output_directory=$1
    # calculate variance of unfiltered data
    calc_data_variance "$output_directory"
    plot_data_variance "$output_directory"
}

function calc_data_variance
{
    output_directory=$1
    data_dir="$output_directory/data"
    calc_variance="$GEODIAG_TOOLS/statistics/calc_variance.ncl"
    start_ymd=$(mute_ncl $GEODIAG_TOOLS/dataset/query_start_time.ncl "'dataset=\"$data_dir/U850.filtered.daily_anom.all.nc\"'")
    end_ymd=$(mute_ncl $GEODIAG_TOOLS/dataset/query_end_time.ncl "'dataset=\"$data_dir/U850.filtered.daily_anom.all.nc\"'")
    i=0
    for var in $(echo "U850 U200 OLR"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            # calculate variance of unfiltered daily anomalies
            input_data1="$data_dir/$var.daily_anom.$season.nc"
            output_data1="$data_dir/$var.daily_anom.$season.variance.nc"
            notice "Calcuate variance of $var at season $season."
            mute_ncl $calc_variance "'dataset=\"$input_data1\"'" \
                                    "'var=\"$var\"'" \
                                    "start_ymd=$start_ymd" \
                                    "end_ymd=$end_ymd" \
                                    "'output=\"$output_data1\"'" &
            calc_variance_pids[$i]=$!
            i=$((i+1))
            sleep 1 
            # calculate variance of filtered daily anomalies
            input_data2="$data_dir/$var.filtered.daily_anom.$season.nc"
            output_data2="$data_dir/$var.filtered.daily_anom.$season.variance.nc"
            notice "Calcuate variance of $var at season $season."
            mute_ncl $calc_variance "'dataset=\"$input_data2\"'" \
                                    "'var=\"$var\"'" \
                                    "start_ymd=$start_ymd" \
                                    "end_ymd=$end_ymd" \
                                    "'output=\"$output_data2\"'" &
            calc_variance_pids[$i]=$!
            i=$((i+1))
            sleep 1 
            # calculate percentage of unfiltered daily anomaly variance
            mute_ncl $GEODIAG_TOOLS/dataset/div_var.ncl "'dataset1=\"$output_data1\"'" \
                                                        "'dataset2=\"$output_data2\"'" \
                                                        "'var=\"$var\"'" \
                                                        "'output=\"$data_dir/$var.daily_anom.$season.variance_percentage.nc\"'"
        done
    done
    for (( i = 0; i < ${#calc_variance_pids[@]}; ++i )); do
        notice "Waiting job ${calc_variance_pids[$i]} ..."
        wait ${calc_variance_pids[$i]}
    done
}

function plot_data_variance
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    for data in $(ls "$data_dir"/U850.*.variance.nc); do
        mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_U850_variance.ncl "'dataset=\"$data\"'" \
                                                                          "'output_dir=\"$figure_dir\"'"
    done
    for data in $(ls "$data_dir"/U850.*.variance_percentage.nc); do
        mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_U850_variance_percentage.ncl "'dataset=\"$data\"'" \
                                                                                     "'output_dir=\"$figure_dir\"'"
    done
    for data in $(ls "$data_dir"/U200.*.variance.nc); do
        mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_U200_variance.ncl "'dataset=\"$data\"'" \
                                                                          "'output_dir=\"$figure_dir\"'"
    done
    for data in $(ls "$data_dir"/U200.*.variance_percentage.nc); do
        mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_U200_variance_percentage.ncl "'dataset=\"$data\"'" \
                                                                                     "'output_dir=\"$figure_dir\"'"
    done
    for data in $(ls "$data_dir"/OLR.*.variance.nc); do
        mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_OLR_variance.ncl "'dataset=\"$data\"'" \
                                                                         "'output_dir=\"$figure_dir\"'"
    done
    for data in $(ls "$data_dir"/OLR.*.variance_percentage.nc); do
        mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_OLR_variance_percentage.ncl "'dataset=\"$data\"'" \
                                                                                    "'output_dir=\"$figure_dir\"'"
    done
}
