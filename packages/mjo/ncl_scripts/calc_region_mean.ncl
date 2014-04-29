load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("season")
    check_cmd_arg("region")
    check_cmd_arg("output")

    fin = addfile(dataset, "r")

    ; --------------------------------------------------------------------------
    ; calcuate region mean of variable
    if (var .eq. "U850") then
        if (season .eq. "boreal_winter") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    163.75d0, 191.25d0, -13.75d0, 1.25d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    68.75d0, 96.25d0, -16.25d0, -1.25d0)
            else
                report_error("Unknown region "+region+"!")
            end if
            end if
        else if (season .eq. "boreal_summer") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    118.75d0, 146.25d0, 3.75d0, 21.25d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    68.75d0, 96.25d0, 3.75d0, 21.25d0)
            else
                report_error("Unknown region "+region+"!")
            end if
            end if
        else
            report_error("Unknown season "+season+"!")
        end if
        end if
    else if (var .eq. "U200") then
        if (season .eq. "boreal_winter") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    123.75d0, 151.25d0, 3.75d0, 21.25d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    56.25d0, 78.75d0, 3.75d0, 21.25d0)
            else
                report_error("Unknown region "+region+"!")
            end if
            end if
        else if (season .eq. "boreal_summer") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    123.75d0, 151.25d0, 3.75d0, 21.25d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    43.75d0, 71.25d0, -16.25d0, 1.25d0)
            else
                report_error("Unknown region "+region+"!")
            end if
            end if
        else
            report_error("Unknown season "+season+"!")
        end if
        end if
    else if (var .eq. "OLR") then
        if (season .eq. "boreal_winter") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    160.0d0, 185.0d0, -20.0d0, -5.0d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    75.0d0, 100.0d0, -10.0d0, 5.0d0)
            else
                report_error("Unknown region "+region+"!")
            end if
            end if
        else if (season .eq. "boreal_summer") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    115.0d0, 140.0d0, 10.0d0, 25.0d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    75.0d0, 100.0d0, -10.0d0, 5.0d0)
            else
                report_error("Unknown region "+region+"!")
            end if
            end if
        else
            report_error("Unknown season "+season+"!")
        end if
        end if
    else if (var .eq. "PRECT") then
        if (season .eq. "boreal_winter") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    160.0d0, 185.0d0, -20.0d0, -5.0d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    75.0d0, 100.0d0, -10.0d0, -5.0d0)
            end if
            end if
        else if (season .eq. "boreal_summer") then
            if (region .eq. "west_pacific") then
                var_mean = calc_region_mean(fin, var, \
                    115.0d0, 140.0d0, 10.0d0, 25.0d0)
            else if (region .eq. "indian_ocean") then
                var_mean = calc_region_mean(fin, var, \
                    75.0d0, 100.0d0, -10.0d0, -5.0d0)
            end if
            end if
        else
            report_error("Under construction! "+var+" "+season)
        end if
        end if
    end if
    end if
    end if
    end if

    ; --------------------------------------------------------------------------
    ; output region mean of variable
    ; only time dimension remains
    system("rm -f "+output)
    fout = addfile(output, "c")

    setfileoption(fout, "DefineMode", True)

    filedimdef(fout, (/"time"/), (/dimsizes(var_mean)/), (/False/))

    filevardef(fout, "time", getfilevartypes(fin, "time"), "time")
    filevarattdef(fout, "time", fin->time)
    filevardef(fout, var, typeof(var_mean), (/"time"/))
    fout->$var$@long_name = fin->$var$@long_name+" ("+region+" mean)"
    fout->$var$@units = fin->$var$@units

    setfileoption(fout, "DefineMode", False)

    fout->time = (/fin->time/)
    fout->$var$ = (/var_mean/)

    notice("File "+output+" is created.")

end
