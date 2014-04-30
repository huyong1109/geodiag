#!/bin/bash

trap "exit 1" TERM
export top_pid=$$

if [[ -t 1 ]]; then
    console_redirected=false
else
    console_redirected=true
fi

function notice
{
    message=$1
    echo "[$(add_color Notice "green bold")]: $message"
}

function report_warning
{
    message=$1
    echo "[$(add_color Warning "yellow bold")]: $message"
}

function report_error
{
    message=$1
    echo "[$(add_color Error "red bold")]: $message" >&2
    kill -s TERM $top_pid
}

function report_error_noexit
{
    message=$1
    echo -e "[$(add_color Error "red bold")]: $message" >&2
}

function get_answer
{
    read -e -p "> " ans
    echo $ans
}

function check_file_existence
{
    dir=$(dirname $1)
    base=$(basename $1)
    files=$(find $dir -name $base)
    if [[ "$files" == "" ]]; then
        report_error "File \"$file\" does not exist!"
    fi
    for file in $files; do
        if [ ! -f $file ]; then
            report_error "File \"$file\" does not exist!"
        fi
    done
}

function check_directory_existence
{
    dir=$1
    if [ ! -d $dir ]; then
        report_error "Directory \"$dir\" does not exist!"
    fi
}

function add_color
{
    if [[ $console_redirected == true ]]; then
        echo -n $1
    else
        if [[ $2 == *red* ]]; then
            colored_message="$colored_message$(tput setaf 1)"
        elif [[ $2 == *green* ]]; then
            colored_message="$colored_message$(tput setaf 2)"
        elif [[ $2 == *yellow* ]]; then
            colored_message="$colored_message$(tput setaf 3)"
        elif [[ $2 == *blue* ]]; then
            colored_message="$colored_message$(tput setaf 4)"
        elif [[ $2 == *magenta* ]]; then
            colored_message="$colored_message$(tput setaf 5)"
        fi
        if [[ $2 == *bold* ]]; then
            colored_message="$colored_message$(tput bold)"
        fi
        colored_message="$colored_message$1$(tput sgr0)"
        echo -n $colored_message
    fi
}

function get_config_entry
{
    config_file=$1
    entry_name=$2
    tmp=$(grep "^$entry_name" $config_file)
    if [[ "$tmp" == "" ]]; then
        report_error "No match entry for \"$entry_name\" in $config_file!"
    fi
    entry_value=$(echo $tmp | cut -d '=' -f 2)
    echo ${entry_value/^ */}
}

function should_run
{
    diag_stages=$1
    stage=$2
    if [[ $diag_stages == "" || $diag_stages == "all" ]]; then
        return 0
    fi
    if [[ $diag_stages =~ $stage ]]; then
        return 0
    fi
    return 1
}

function mute_ncl
{
    ncl_cmd=$*
    eval ncl $ncl_cmd | grep -v "^ \(Copyright\|University Corporation for Atmospheric Research\|NCAR Command Language Version\|The use of this software is governed by a License Agreement\|See http://www.ncl.ucar.edu/ for more details\)"
}

