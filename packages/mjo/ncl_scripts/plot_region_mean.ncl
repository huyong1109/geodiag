load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("season")
    check_cmd_arg("region")
    check_cmd_arg("flag")
    check_cmd_arg("figure_dir")

    fin = addfile(dataset, "r")

    figure_name = var+"."+flag+"."+season+"."+region+".mean"
    wks = gsn_open_wks("pdf", figure_dir+"/"+figure_name)

    res = True
    res@vpWidthF = 0.8
    res@vpHeightF = 0.4
    res@xyLineThicknessF = 3.0
    res@tiXAxisString = "time level"
    res@tiYAxisString = var

    time = ispan(0, dimsizes(fin->time)-1, 1)
    plot = gsn_csm_xy(wks, time, fin->$var$, res)

    notice("Figure "+figure_name+".pdf is created.")

end
