#!/bin/bash

function notice
{
    message=$1
    echo "[Notice]: $message"
}

function report_warning
{
    message=$1
    echo "[Warning]: $message"
}

function report_error
{
    message=$1
    echo "[Error]: $message"
    exit
}

function check_file_exist
{
    file=$1
    if [ ! -f $file ]; then
        report_error "File \"$file\" does not exist!"
    fi
}
