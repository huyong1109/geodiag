#!/bin/bash

function prepare_model_data
{
    notice "Prepare model data."
    model_data_root=$1
    # concatenate data
    model_data_pattern=$2
    model_data_files=$(find $model_data_root -name "$model_data_pattern")
    model_data_list=$3
    internal_data_map=$4
    output_directory=$5
    cat_data "$model_data_files" "$model_data_list" "$internal_data_map" \
             "$output_directory"
    # get daily anomalies
    
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
    cat_var="ncl $GEODIAG_TOOLS/dataset/cat_var.ncl"
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
            eval $cat_var "'datasets=\"$(echo $model_data_files)\"'" \
                          "'var=\"$model_data\"'" \
                          "'var_alias=\"$var_alias\"'" \
                          "'output=\"$data_dir/$var_alias.nc\"'" \
                          "freq=1" &
        else
            eval $cat_var "'datasets=\"$(echo $model_data_files)\"'" \
                          "'var=\"$model_data\"'" \
                          "'output=\"$data_dir/$model_data.nc\"'" \
                          "freq=1" &
        fi
        cat_var_pids[$i]=$!
        i=$((i+1))
    done
    for ((i = 0; i < ${#cat_var_pids[@]}; ++i)); do
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
