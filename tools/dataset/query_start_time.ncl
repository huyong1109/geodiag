load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")

    fin = addfile(dataset, "r")

    system("echo "+cd_string(fin->time(0), "%Y%N%D"))

end
