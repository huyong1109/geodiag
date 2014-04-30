load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("data_dir")
    check_cmd_arg("figure_dir")

    wks = gsn_open_wks("pdf", figure_dir+"/variance")

    gsn_define_colormap(wks, "amwg")

    res_panel = True

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
    res_plot@gsnSpreadColors = True
    res_plot@gsnLeftStringFontHeightF = 0.015

    seasons = (/"all","boreal_winter","boreal_summer"/)
    vars = (/"U850","U200","OLR"/)

    ;min_level = (/10,10,10/)
    ;max_level = (/50,50,50/)
    ;level_spaceing = (/5,5,5/)

    plots = new((/dimsizes(vars)/), graphic)

    do i = 0, dimsizes(seasons)-1
        do j = 0, dimsizes(vars)-1
            fin = addfile(data_dir+"/"+vars(j)+".unfiltered.daily_anom."+seasons(i)+".variance.nc", "r")
            ;res_plot@cnLevelSelectionMode = "ManualLevels"
            ;res_plot@cnMinLevelValF = min_level(j)
            ;res_plot@cnMaxLevelValF = max_level(j)
            ;res_plot@cnLevelSpacingF = level_spaceing(j)
            res_plot@gsnLeftString = vars(j)
            res_plot@gsnRightString = ""
            plots(j) = gsn_csm_contour_map(wks, fin->$vars(j)$, res_plot)
        end do
        res_panel@txString = seasons(i)+" variance"
        gsn_panel(wks, plots, (/dimsizes(vars),1/), res_panel)
    end do

    notice("Figure variance.pdf is created.")

end
