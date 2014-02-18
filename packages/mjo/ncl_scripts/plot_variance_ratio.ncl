load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("data_dir")
    check_cmd_arg("figure_dir")

    wks = gsn_open_wks("pdf", figure_dir+"/variance_ratio")

    gsn_define_colormap(wks, "amwg")

    res_panel = True
    res_panel@gsnPanelLabelBar = True
    res_panel@lbLabelFontHeightF = 0.0125

    res_plot = True
    res_plot@gsnDraw = False
    res_plot@gsnFrame = False
    res_plot@mpCenterLonF = 180.0
    res_plot@mpMinLonF = 30
    res_plot@mpMaxLonF = 300
    res_plot@mpMinLatF = -30
    res_plot@mpMaxLatF =  30
    res_plot@cnLinesOn = False
    res_plot@cnFillOn = True
    res_plot@lbLabelBarOn = False
    res_plot@gsnSpreadColors = True
    res_plot@cnLevelSelectionMode = "ManualLevels"
    res_plot@cnMinLevelValF = 0.1
    res_plot@cnMaxLevelValF = 0.5
    res_plot@cnLevelSpacingF = 0.05
    res_plot@gsnLeftStringFontHeightF = 0.015

    seasons = (/"all","boreal_winter","boreal_summer"/)
    vars = (/"U850","U200","OLR"/)

    plots = new((/dimsizes(vars)/), graphic)

    do i = 0, dimsizes(seasons)-1
        do j = 0, dimsizes(vars)-1
            fin = addfile(data_dir+"/"+vars(j)+".daily_anom."+seasons(i)+".variance_ratio.nc", "r")
            res_plot@gsnLeftString = vars(j)
            res_plot@gsnRightString = ""
            plots(j) = gsn_csm_contour_map(wks, fin->$vars(j)$, res_plot)
        end do
        res_panel@txString = seasons(i)+" variance ratio (fitered variable)"
        gsn_panel(wks, plots, (/dimsizes(vars),1/), res_panel)
    end do

    notice("Figure variance_ratio.pdf is created.")

end
