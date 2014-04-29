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
    # calculate lag correlation
    calc_lag_lon "$output_directory"
    plot_lag_lon "$output_directory"
    calc_lag_lat "$output_directory"
    plot_lag_lat "$output_directory"
    # calculate EOF
    #calc_eof "$output_directory"
}

function calc_variance
{
    output_directory=$1
    data_dir="$output_directory/data"
    start_ymd=$(mute_ncl \"$GEODIAG_TOOLS/dataset/query_start_time.ncl\" \
        "'dataset=\"$data_dir/U850.filtered.daily_anom.all.nc\"'")
    end_ymd=$(mute_ncl \"$GEODIAG_TOOLS/dataset/query_end_time.ncl\" \
        "'dataset=\"$data_dir/U850.filtered.daily_anom.all.nc\"'")
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                notice "Calcuate variance of $(add_color $flag 'bold') $(add_color $var 'bold') at season $season."
                mute_ncl \"$GEODIAG_TOOLS/statistics/calc_variance.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                    "'var=\"$var\"'" \
                    "start_ymd=$start_ymd" \
                    "end_ymd=$end_ymd" \
                    "'output=\"$data_dir/$var.$flag.daily_anom.$season.variance.nc\"'" &
                calc_variance_pids[$i]=$!
                i=$((i+1))
                sleep 1 
            done
        done
    done
    for (( i = 0; i < ${#calc_variance_pids[@]}; ++i )); do
        notice "Waiting job ${calc_variance_pids[$i]} ..."
        wait ${calc_variance_pids[$i]}
    done
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            # calculate variance ratio of unfiltered daily anomaly variance
            mute_ncl \"$GEODIAG_TOOLS/dataset/div_var.ncl\" \
                "'dataset1=\"$data_dir/$var.filtered.daily_anom.$season.variance.nc\"'" \
                "'dataset2=\"$data_dir/$var.unfiltered.daily_anom.$season.variance.nc\"'" \
                "'var=\"$var\"'" \
                "'output=\"$data_dir/$var.daily_anom.$season.variance_ratio.nc\"'"
            i=$((i+1))
            sleep 1 
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
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                for flag in $(echo "unfiltered filtered"); do
                    mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/calc_region_mean.ncl \
                        "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                        "'var=\"$var\"'" \
                        "'season=\"$season\"'" \
                        "'region=\"$region\"'" \
                        "'output=\"$data_dir/$var.$flag.daily_anom.$season.$region.nc\"'"
                done
            done
        done
    done
}

function plot_region_mean
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                for flag in $(echo "unfiltered filtered"); do
                    mute_ncl $GEODIAG_PACKAGES/mjo/ncl_scripts/plot_region_mean.ncl \
                        "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.$region.nc\"'" \
                        "'var=\"$var\"'" \
                        "'season=\"$season\"'" \
                        "'region=\"$region\"'" \
                        "'flag=\"$flag\"'" \
                        "'figure_dir=\"$figure_dir\"'"
                done
            done
        done
    done

}

function calc_time_spectra
{
    output_directory=$1
    data_dir="$output_directory/data"
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/calc_time_spectra.ncl\" \
                    "'dataset=\"$data_dir/$var.unfiltered.daily_anom.$season.$region.nc\"'" \
                    "'var=\"$var\"'" \
                    "'output=\"$data_dir/$var.unfiltered.daily_anom.$season.$region.spectrum.nc\"'"
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

function calc_lag_lon
{
    output_directory=$1
    data_dir="$output_directory/data"
    refer_var="OLR"
    for var in $(echo "U850 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/calc_lag_lon.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                    "'refer_dataset=\"$data_dir/$refer_var.$flag.daily_anom.$season.indian_ocean.nc\"'" \
                    "'var=\"$var\"'" \
                    "'refer_var=\"$refer_var\"'" \
                    "'output=\"$data_dir/$var.$flag.daily_anom.$season.lag_lon.nc\"'"
            done
        done
    done
}

function plot_lag_lon
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    refer_var="OLR"
    for var in $(echo "U850 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/plot_lag_lon.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.lag_lon.nc\"'" \
                    "'var=\"$var\"'" \
                    "'refer_var=\"$refer_var\"'" \
                    "'season=\"$season\"'" \
                    "'flag=\"$flag\"'" \
                    "'figure_dir=\"$figure_dir\"'"
            done
        done
    done
}

function calc_lag_lat
{
    output_directory=$1
    data_dir="$output_directory/data"
    refer_var="OLR"
    for var in $(echo "U850 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/calc_lag_lat.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                    "'refer_dataset=\"$data_dir/$refer_var.$flag.daily_anom.$season.indian_ocean.nc\"'" \
                    "'var=\"$var\"'" \
                    "'refer_var=\"$refer_var\"'" \
                    "'output=\"$data_dir/$var.$flag.daily_anom.$season.lag_lat.nc\"'"
            done
        done
    done
}

function plot_lag_lat
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    refer_var="OLR"
    for var in $(echo "U850 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                mute_ncl \"$GEODIAG_PACKAGES/mjo/ncl_scripts/plot_lag_lat.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.lag_lat.nc\"'" \
                    "'var=\"$var\"'" \
                    "'refer_var=\"$refer_var\"'" \
                    "'season=\"$season\"'" \
                    "'flag=\"$flag\"'" \
                    "'figure_dir=\"$figure_dir\"'"
            done
        done
    done
}

function calc_eof
{
    output_directory=$1
    data_dir="$output_directory/data"
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            echo "$var $season"
            mute_ncl \"$GEODIAG_TOOLS/statistics/calc_eof.ncl\" \
                "'dataset=\"$data_dir/$var.filtered.daily_anom.$season.nc\"'" \
                "'var=\"$var\"'" \
                "num_eof=3"
        done
    done
}
