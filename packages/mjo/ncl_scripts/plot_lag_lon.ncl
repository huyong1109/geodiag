load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("data_dir")
    check_cmd_arg("figure_dir")

    wks = gsn_open_wks("pdf", figure_dir+"/lag_lon")

    colormap = (/(/1.00,1.00,1.00/), \
                 (/0.00,0.00,0.00/), \
                 (/0.17,0.16,0.29/), \
                 (/0.25,0.26,0.57/), \    
                 (/0.26,0.26,0.58/), \    
                 (/0.28,0.26,0.58/), \    
                 (/0.28,0.36,0.64/), \    
                 (/0.36,0.46,0.71/), \    
                 (/0.39,0.67,0.85/), \    
                 (/0.51,0.80,0.94/), \    
                 (/0.71,0.89,0.93/), \    
                 (/1.00,1.00,1.00/), \   
                 (/1.00,0.92,0.76/), \    
                 (/0.98,0.78,0.61/), \    
                 (/0.96,0.66,0.48/), \    
                 (/0.94,0.47,0.35/), \    
                 (/0.93,0.39,0.25/), \    
                 (/0.93,0.32,0.25/), \    
                 (/0.84,0.22,0.24/), \    
                 (/0.56,0.18,0.19/), \    
                 (/0.30,0.14,0.16/)/)    

    gsn_define_colormap(wks, colormap)

    res_panel = True
    res_panel@gsnMaximize = True

    res_plot = True
    res_plot@gsnDraw = False
    res_plot@gsnFrame = False
    res_plot@cnLinesOn = False
    res_plot@cnFillOn = True
    res_plot@cnLevelSelectionMode = "ManualLevels"
    res_plot@cnMinLevelValF = -0.9
    res_plot@cnMaxLevelValF =  0.9
    res_plot@cnLevelSpacingF = 0.1
    res_plot@gsnSpreadColors = True
    res_plot@lbLabelFontHeightF = 0.015
    res_plot@pmLabelBarWidthF = 0.8
    res_plot@pmLabelBarHeightF = 0.05
    res_plot@pmLabelBarOrthogonalPosF = 0.1
    res_plot@tiXAxisOffsetYF = 0.1
    res_plot@vpWidthF = 0.8
    res_plot@vpHeightF = 0.4
    res_plot@tiYAxisString = "lag (Day)"
    res_plot@lbTitleString = "IO: 75-100E, 10S-5N"
    res_plot@lbTitleJust = "BottomLeft"
    res_plot@lbTitleFontHeightF = "0.015"

    seasons = (/"boreal_winter","boreal_summer"/)
    vars = (/"U850","U200","OLR"/)

    plots = new((/dimsizes(vars)/), graphic)

    do i = 0, dimsizes(seasons)-1
        do j = 0, dimsizes(vars)-1
            fin = addfile(data_dir+"/"+vars(j)+".daily_anom."+seasons(i)+".lag_lon.nc", "r")
            res_plot@gsnLeftString = "lag-longitude of "+vars(j)+" refer to IO at "+seasons(i)
            plots(j) = gsn_csm_contour(wks, transpose(fin->ccr), res_plot)
        end do
        gsn_panel(wks, plots, (/dimsizes(vars),1/), res_panel)
    end do

    notice("Figure lag_lon.pdf is created.")

end
