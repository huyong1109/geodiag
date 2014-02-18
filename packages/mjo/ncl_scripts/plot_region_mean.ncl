load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("data_dir")
    check_cmd_arg("figure_dir")

    wks = gsn_open_wks("pdf", figure_dir+"/region_mean")

    res_panel = True

    res_plot = True
    res_plot@gsnDraw = False
    res_plot@gsnFrame = False
    res_plot@vpWidthF = 0.8
    res_plot@vpHeightF = 0.4
    res_plot@xyLineThicknessF = 3.0

    seasons = (/"boreal_winter","boreal_summer"/)
    regions = (/"indian_ocean","west_pacific"/)
    vars = (/"U850","U200","OLR"/)

    plots = new((/dimsizes(vars)/), graphic)

    do i = 0, dimsizes(seasons)-1
        do j = 0, dimsizes(regions)-1
            do k = 0, dimsizes(vars)-1
                fin = addfile(data_dir+"/"+vars(k)+".daily_anom."+seasons(i)+"."+regions(j)+".nc", "r")
                time = ispan(0, dimsizes(fin->time)-1, 1)
                res_plot@tiXAxisString = "time level"
                res_plot@tiYAxisString = vars(k)
                plots(k) = gsn_csm_xy(wks, time, fin->$vars(k)$, res_plot)
                delete(time)
            end do
            res_panel@txString = seasons(i)+" "+regions(j)+" mean"
            gsn_panel(wks, plots, (/dimsizes(vars),1/), res_panel)
        end do
    end do

    notice("Figure region_mean.pdf is created.")

end
