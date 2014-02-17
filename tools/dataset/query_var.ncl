load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")

    fin = addfile(dataset, "r")

    if (isdefined("i0")) then
        if (isdefined("i1")) then
            if (isdefined("i2")) then
                if (isdefined("i3")) then
                    res = fin->$var$(i0,i1,i2,i3)
                else
                    res = fin->$var$(i0,i1,i2)
                end if
            else
                res = fin->$var$(i0,i1)
            end if
        else
            res = fin->$var$(i0)
        end if
    else
        report_error("Argument i0 must be provided!")
    end if

    system("echo "+res)

end
