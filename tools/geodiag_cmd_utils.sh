#!/bin/bash

function notice
{
    message=$1
    echo -e "[Notice]: $message"
}

function report_warning
{
    message=$1
    echo -e "[Warning]: $message"
}

function report_error
{
    message=$1
    echo -e "[Error]: $message"
    exit
}

function check_file_exist
{
    file=$1
    if [ ! -f $file ]; then
        report_error "File \"$file\" does not exist!"
    fi
}
