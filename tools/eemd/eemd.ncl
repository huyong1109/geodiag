procedure eemd_plot_imf(wks, x, imf, res)
local dims, plots, i, res_panel
begin

    dims = dimsizes(imf)

    res@gsnDraw = False
    res@gsnFrame = False
    res@tmYLTickSpacingF = 0.5
    res@xyLineThicknessF = 3.0
    res@vpWidthF = 24.0
    res@vpHeightF = 4.0

    plots = new(dims(0), graphic)

    do i = 0, dims(0)-1
        plots(i) = gsn_csm_xy(wks, x, imf(i,:), res)
    end do

    res_panel = True
    res_panel@gsnMaximize = True

    gsn_panel(wks, plots, (/dims(0),1/), res_panel)

end
