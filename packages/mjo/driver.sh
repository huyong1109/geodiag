#!/bin/bash

source $GEODIAG_ROOT/tools/bash_utils.sh

MJO_ROOT=$GEODIAG_ROOT/packages/mjo

function mjo_help
{
	notice "$(add_color mjo 'magenta bold') diagnosis package usage:"
	echo
	echo -e "\tgeodiag $(add_color run bold) $(add_color mjo 'magenta bold') <variable map file> <output directory>"
}

function mjo_run
{
	report_error "MJO diagnosis package is under construction!"
}
