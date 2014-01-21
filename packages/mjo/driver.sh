#!/bin/bash

source $GEODIAG_ROOT/tools/geodiag_cmd_utils.sh

MJO_ROOT=$GEODIAG_ROOT/packages/mjo

function mjo_help
{
	notice "MJO diagnosis package usage:"
	echo
	echo -e "\tgeodiag run mjo <variable map file> <output directory>"
}

function mjo_run
{
	report_error "MJO diagnosis package is under construction!"
}
