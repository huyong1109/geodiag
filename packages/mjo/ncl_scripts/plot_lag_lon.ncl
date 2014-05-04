load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("refer_var")
    check_cmd_arg("data_dir")
    check_cmd_arg("figure_dir")

    wks = gsn_open_wks("pdf", figure_dir+"/lag_lon")

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

    res_panel = True

    res_plot = True
    res_plot@gsnDraw = False
    res_plot@gsnFrame = False
    res_plot@cnLevelSelectionMode = "ManualLevels"
    res_plot@cnMinLevelValF = -0.8
    res_plot@cnMaxLevelValF =  0.8
    res_plot@cnLevelSpacingF = 0.1
    res_plot@cnLineThicknessF = 2.0
    res_plot@cnInfoLabelOn = False
    res_plot@cnLineLabelPlacementMode = "Computed"
    res_plot@cnLineLabelDensityF = 2.0
    res_plot@cnLineLabelInterval = 1
    res_plot@gsnSpreadColors = True
    res_plot@lbLabelFontHeightF = 0.015
    res_plot@pmLabelBarWidthF = 0.6
    res_plot@pmLabelBarOrthogonalPosF = 0.1
    res_plot@tiXAxisOffsetYF = 0.1
    res_plot@vpWidthF = 0.6
    res_plot@vpHeightF = 0.4
    res_plot@tiYAxisString = "Lag (Day)"
    res_plot@tiYAxisFontHeightF = 0.02
    res_plot@lbTitleFuncCode = "~"
    res_plot@lbTitleString = "Refer region: 75~S~o~N~-100~S~o~N~E, 10~S~o~N~S-5~S~o~N~N  Refer var: "+refer_var
    res_plot@lbTitleJust = "BottomLeft"
    res_plot@lbTitleFontHeightF = 0.015
    res_plot@gsnLeftString = ""
    res_plot@gsnContourZeroLineThicknessF = 3.0
    res_plot@gsnContourNegLineDashPattern = 1
    res_plot@pmTickMarkDisplayMode = "Always"

    flags = (/"unfiltered","filtered"/)
    seasons = (/"boreal_winter","boreal_summer"/)
    season_alias = (/"winter (Nov-Apr)", "summer (May-Oct)"/)

    plots = new((/dimsizes(seasons)/), graphic)

    do i = 0, dimsizes(flags)-1
        do j = 0, dimsizes(seasons)-1
            f0 = addfile(data_dir+"/OLR."+flags(i)+".daily_anom."+seasons(j)+".lag_lon.nc", "r")
            f1 = addfile(data_dir+"/U850."+flags(i)+".daily_anom."+seasons(j)+".lag_lon.nc", "r")
            res_plot@gsnRightString = season_alias(j)
            res_plot@cnLinesOn = False
            res_plot@cnFillOn = True
            plots(j) = gsn_csm_contour(wks, transpose(f0->ccr), res_plot)
            res_plot@cnLinesOn = True
            res_plot@cnFillOn = False
            plot = gsn_csm_contour(wks, transpose(f1->ccr), res_plot)
            overlay(plots(j), plot)
        end do
        gsn_panel(wks, plots, (/1,dimsizes(seasons)/), res_panel)
    end do

    notice("Figure lag_lon.pdf is created.")

end
