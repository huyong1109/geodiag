#!/bin/bash

function run_level_1
{
    notice "Run $(add_color level-1 'red bold') $(add_color mjo 'magenta bold') diagnostics."
    output_directory=$1
    # calculate variance
    calc_variance "$output_directory"
    plot_variance "$output_directory"
    plot_variance_ratio "$output_directory"
    # calculate region mean
    calc_region_mean "$output_directory"
    plot_region_mean "$output_directory"
    # calculate time spectra
    calc_time_spectra "$output_directory"
    plot_time_spectra "$output_directory"
}

function calc_variance
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
            # calculate variance ratio of unfiltered daily anomaly variance
            mute_ncl $GEODIAG_TOOLS/dataset/div_var.ncl "'dataset1=\"$output_data2\"'" \
                                                        "'dataset2=\"$output_data1\"'" \
                                                        "'var=\"$var\"'" \
                                                        "'output=\"$data_dir/$var.daily_anom.$season.variance_ratio.nc\"'"
        done
    done
    for (( i = 0; i < ${#calc_variance_pids[@]}; ++i )); do
        notice "Waiting job ${calc_variance_pids[$i]} ..."
        wait ${calc_variance_pids[$i]}
    done
}

function plot_variance_ratio
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/plot_variance_ratio.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function plot_variance
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/plot_variance.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function calc_region_mean
{
    output_directory=$1
    data_dir="$output_directory/data"
    for var in $(echo "U850 U200 OLR"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                # calculate region mean of unfiltered daily anomalies
                data="$data_dir/$var.daily_anom.$season.nc"
                mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/calc_region_mean.ncl \
                    "'dataset=\"$data\"'" \
                    "'var=\"$var\"'" \
                    "'season=\"$season\"'" \
                    "'region=\"$region\"'" \
                    "'output=\"$data_dir/$var.daily_anom.$season.$region.nc\"'"
                # calculate region mean of filtered daily anomalies
                data="$data_dir/$var.filtered.daily_anom.$season.nc"
                mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/calc_region_mean.ncl \
                    "'dataset=\"$data\"'" \
                    "'var=\"$var\"'" \
                    "'season=\"$season\"'" \
                    "'region=\"$region\"'" \
                    "'output=\"$data_dir/$var.filtered.daily_anom.$season.$region.nc\"'"
            done
        done
    done
}

function plot_region_mean
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/plot_region_mean.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function calc_time_spectra
{
    output_directory=$1
    data_dir="$output_directory/data"
    for var in $(echo "U850 U200 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                data="$data_dir/$var.daily_anom.$season.$region.nc"
                mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/calc_time_spectra.ncl \
                    "'dataset=\"$data\"'" \
                    "'var=\"$var\"'" \
                    "'output=\"$data_dir/$var.daily_anom.$season.$region.spectrum.nc\"'"
            done
        done
    done
}

function plot_time_spectra
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/plot_time_spectra.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}
