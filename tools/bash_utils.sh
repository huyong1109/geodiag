#!/bin/bash

function notice
{
    message=$1
    echo -e "[$(add_color Notice "green bold")]: $message"
}

function report_warning
{
    message=$1
    echo -e "[$(add_color Warning "yellow bold")]: $message"
}

function report_error
{
    message=$1
    echo -e "[$(add_color Error "red bold")]: $message"
    exit
}

function check_file_exist
{
    file=$1
    if [ ! -f $file ]; then
        report_error "File \"$file\" does not exist!"
    fi
}

function add_color
{
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
}
