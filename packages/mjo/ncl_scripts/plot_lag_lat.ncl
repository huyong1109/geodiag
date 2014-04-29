load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("refer_var")
    check_cmd_arg("season")
    check_cmd_arg("flag")
    check_cmd_arg("figure_dir")

    fin = addfile(dataset, "r")

    figure_name = var+"."+flag+"."+season+".lag_lat"
    wks = gsn_open_wks("pdf", figure_dir+"/"+figure_name)

    colormap = (/(/1.00,1.00,1.00/), \
                 (/0.00,0.00,0.00/), \
                 (/0.07,0.07,0.13/), \   
                 (/0.18,0.19,0.32/), \
                 (/0.14,0.24,0.51/), \
                 (/0.18,0.33,0.57/), \
                 (/0.24,0.37,0.60/), \
                 (/0.32,0.43,0.64/), \
                 (/0.46,0.65,0.80/), \
                 (/0.59,0.77,0.87/), \
                 (/0.75,0.89,0.92/), \
                 (/0.99,0.91,0.75/), \
                 (/0.96,0.77,0.61/), \
                 (/0.93,0.65,0.49/), \
                 (/0.88,0.45,0.37/), \
                 (/0.87,0.35,0.28/), \
                 (/0.84,0.22,0.22/), \
                 (/0.60,0.17,0.20/), \
                 (/0.35,0.13,0.13/), \
                 (/0.15,0.07,0.06/)/)

    gsn_define_colormap(wks, colormap)

    res = True
    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF = -0.8
    res@cnMaxLevelValF =  0.8
    res@cnLevelSpacingF = 0.1
    res@gsnSpreadColors = True
    res@lbLabelFontHeightF = 0.015
    res@pmLabelBarWidthF = 0.8
    res@pmLabelBarHeightF = 0.05
    res@pmLabelBarOrthogonalPosF = 0.1
    res@tiXAxisOffsetYF = 0.1
    res@vpWidthF = 0.6
    res@vpHeightF = 0.4
    res@tiYAxisString = "Lag (Day)"
    res@tiYAxisFontHeightF = 0.02
    res@lbTitleString = "IO: 75-100E, 10S-5N"
    res@lbTitleJust = "BottomLeft"
    res@lbTitleFontHeightF = "0.015"
    res@gsnLeftString = "lag-latitude of "+var+" refer to "+refer_var+" on IO at "+season
    res@gsnLeftStringFontHeightF = 0.015

    plot = gsn_csm_contour(wks, transpose(fin->ccr), res)

    notice("Figure "+figure_name+".pdf is created.")

end
