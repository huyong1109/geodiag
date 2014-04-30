load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("data_dir")
    check_cmd_arg("figure_dir")

    wks = gsn_open_wks("pdf", figure_dir+"/time_spectra")

    res_panel = True

    res_plot = True
    res_plot@gsnDraw = False
    res_plot@gsnFrame = False
    res_plot@vpWidthF = 0.8
    res_plot@vpHeightF = 0.4
    res_plot@xyLineThicknessF = 3.0
    res_plot@xyLineColors = (/"black","red","blue","blue"/)

    seasons = (/"boreal_winter","boreal_summer"/)
    regions = (/"indian_ocean","west_pacific"/)
    vars = (/"U850","U200","OLR"/)
    flags = (/"unfiltered","filtered"/)

    plots = new((/dimsizes(vars),dimsizes(flags)/), graphic)

    do i = 0, dimsizes(seasons)-1
        do j = 0, dimsizes(regions)-1
            do k = 0, dimsizes(vars)-1
                do l = 0, dimsizes(flags)-1
                    fin = addfile(data_dir+"/"+vars(k)+"."+flags(l)+".daily_anom."+seasons(i)+"."+regions(j)+".spectrum.nc", "r")
                    res_plot@tiXAxisString = "frequency"
                    res_plot@tiYAxisString = vars(k)
                    plots(k,l) = gsn_csm_xy(wks, fin->spec@frq, fin->splt, res_plot)
                end do
            end do
            res_panel@txString = seasons(i)+" "+regions(j)+" spectrum"
            gsn_panel(wks, ndtooned(plots), (/dimsizes(vars),dimsizes(flags)/), res_panel)
        end do
    end do

    notice("Figure time_spectra.pdf is created.")

end
