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
    #calc_univar_eof "$output_directory"
    #plot_univar_eof "$output_directory"
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
                notice "Calculate variance of $(add_color $flag 'bold') $(add_color $var 'green') at $season."
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
        #notice "Waiting job ${calc_variance_pids[$i]} ..."
        wait ${calc_variance_pids[$i]}
    done
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            notice "Calculate variance ratio of $(add_color $var 'green') at $season."
            mute_ncl \"$GEODIAG_TOOLS/dataset/div_var.ncl\" \
                "'dataset1=\"$data_dir/$var.filtered.daily_anom.$season.variance.nc\"'" \
                "'dataset2=\"$data_dir/$var.unfiltered.daily_anom.$season.variance.nc\"'" \
                "'var=\"$var\"'" \
                "'output=\"$data_dir/$var.daily_anom.$season.variance_ratio.nc\"'" &
            calc_variance_ratio_pids[$i]=$!
            i=$((i+1))
            sleep 1 
        done
    done
    for (( i = 0; i < ${#calc_variance_ratio_pids[@]}; ++i )); do
        #notice "Waiting job ${calc_variance_ratio_pids[$i]} ..."
        wait ${calc_variance_ratio_pids[$i]}
    done
}

function plot_variance_ratio
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    notice "Plot variance ratio."
    mute_ncl \"$MJO_ROOT/ncl_scripts/plot_variance_ratio.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function plot_variance
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    notice "Plot variance."
    mute_ncl \"$MJO_ROOT/ncl_scripts/plot_variance.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function calc_region_mean
{
    output_directory=$1
    data_dir="$output_directory/data"
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "all boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                for flag in $(echo "unfiltered filtered"); do
                    notice "Calculate region mean of $(add_color $flag 'bold') $(add_color $var 'green') in $region at $season."
                    mute_ncl $MJO_ROOT/ncl_scripts/calc_region_mean.ncl \
                        "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                        "'var=\"$var\"'" \
                        "'season=\"$season\"'" \
                        "'region=\"$region\"'" \
                        "'output=\"$data_dir/$var.$flag.daily_anom.$season.$region.nc\"'" &
                    calc_region_mean_pids[$i]=$!
                    i=$((i+1))
                    sleep 1
                done
            done
        done
    done
    for (( i = 0; i < ${#calc_region_mean_pids[@]}; ++i )); do
        #notice "Waiting job ${calc_region_mean_pids[$i]} ..."
        wait ${calc_region_mean_pids[$i]}
    done
}

function plot_region_mean
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    notice "Plot region mean."
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                for flag in $(echo "unfiltered filtered"); do
                    mute_ncl $MJO_ROOT/ncl_scripts/plot_region_mean.ncl \
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
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for region in $(echo "west_pacific" "indian_ocean"); do
                for flag in $(echo "unfiltered filtered"); do
                    notice "Calculate time spectra of $(add_color $flag 'bold') $(add_color $var 'green') in $region at $season."
                    mute_ncl \"$MJO_ROOT/ncl_scripts/calc_time_spectra.ncl\" \
                        "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.$region.nc\"'" \
                        "'var=\"$var\"'" \
                        "'output=\"$data_dir/$var.$flag.daily_anom.$season.$region.spectrum.nc\"'" &
                    calc_time_spectra_pids[$i]=$!
                    i=$((i+1))
                    sleep 1
                done
            done
        done
    done
    for (( i = 0; i < ${#calc_time_spectra_pids[@]}; ++i )); do
        #notice "Waiting job ${calc_time_spectra_pids[$i]} ..."
        wait ${calc_time_spectra_pids[$i]}
    done
}

function plot_time_spectra
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    notice "Plot time spectra."
    mute_ncl \"$MJO_ROOT/ncl_scripts/plot_time_spectra.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function calc_lag_lon
{
    output_directory=$1
    data_dir="$output_directory/data"
    refer_var="OLR"
    i=0
    for var in $(echo "U850 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                notice "Calculate lag-longitude of $(add_color $flag 'bold') $(add_color $var 'green') at $season."
                mute_ncl \"$MJO_ROOT/ncl_scripts/calc_lag_lon.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                    "'refer_dataset=\"$data_dir/$refer_var.$flag.daily_anom.$season.indian_ocean.nc\"'" \
                    "'var=\"$var\"'" \
                    "'refer_var=\"$refer_var\"'" \
                    "'output=\"$data_dir/$var.$flag.daily_anom.$season.lag_lon.nc\"'" &
                calc_lag_lon_pids[$i]=$!
                i=$((i+1))
                sleep 1
            done
        done
    done
    for (( i = 0; i < ${#calc_lag_lon_pids[@]}; ++i )); do
        #notice "Waiting job ${calc_lag_lon_pids[$i]} ..."
        wait ${calc_lag_lon_pids[$i]}
    done
}

function plot_lag_lon
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    refer_var="OLR"
    mute_ncl \"$MJO_ROOT/ncl_scripts/plot_lag_lon.ncl\" \
        "'refer_var=\"$refer_var\"'" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function calc_lag_lat
{
    output_directory=$1
    data_dir="$output_directory/data"
    refer_var="OLR"
    i=0
    for var in $(echo "U850 OLR"); do
        for season in $(echo "boreal_winter boreal_summer"); do
            for flag in $(echo "unfiltered filtered"); do
                notice "Calculate lag-latitude of $(add_color $flag 'bold') $(add_color $var 'green') at $season."
                mute_ncl \"$MJO_ROOT/ncl_scripts/calc_lag_lat.ncl\" \
                    "'dataset=\"$data_dir/$var.$flag.daily_anom.$season.nc\"'" \
                    "'refer_dataset=\"$data_dir/$refer_var.$flag.daily_anom.$season.indian_ocean.nc\"'" \
                    "'var=\"$var\"'" \
                    "'refer_var=\"$refer_var\"'" \
                    "'output=\"$data_dir/$var.$flag.daily_anom.$season.lag_lat.nc\"'" &
                calc_lag_lat_pids[$i]=$!
                i=$((i+1))
                sleep 1
            done
        done
    done
    for (( i = 0; i < ${#calc_lag_lat_pids[@]}; ++i )); do
        #notice "Waiting job ${calc_lag_lat_pids[$i]} ..."
        wait ${calc_lag_lat_pids[$i]}
    done
}

function plot_lag_lat
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    refer_var="OLR"
    mute_ncl \"$MJO_ROOT/ncl_scripts/plot_lag_lat.ncl\" \
        "'refer_var=\"$refer_var\"'" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}

function calc_univar_eof
{
    output_directory=$1
    data_dir="$output_directory/data"
    i=0
    for var in $(echo "U850 U200 OLR PRECT"); do
        for season in $(echo "boreal_winter"); do
            notice "Calculate univariate EOF of $(add_color filtered 'bold') $(add_color $var 'green') at $season."
            mute_ncl \"$MJO_ROOT/ncl_scripts/calc_univar_eof.ncl\" \
                "'dataset=\"$data_dir/$var.filtered.daily_anom.$season.nc\"'" \
                "'var=\"$var\"'" \
                "num_eof=2" \
                "'output=\"$data_dir/$var.filtered.eof.$season.nc\"'" &
            calc_eof_pids[$i]=$!
            i=$((i+1))
            sleep 1
        done
    done
    notice "The EOF compuation in NCL may be slow, so take a coffee please, if you are watching the screen!" 
    for (( i = 0; i < ${#calc_eof_pids[@]}; ++i )); do
        notice "Waiting job ${calc_eof_pids[$i]} ..."
        wait ${calc_eof_pids[$i]}
    done
}

function plot_univar_eof
{
    output_directory=$1
    data_dir="$output_directory/data"
    figure_dir="$output_directory/figures"
    mute_ncl \"$MJO_ROOT/ncl_scripts/plot_univar_eof.ncl\" \
        "'data_dir=\"$data_dir\"'" \
        "'figure_dir=\"$figure_dir\"'"
}
