load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    PI = atan(1.0)*4.0
    x = fspan(0.0, 2.0*PI, 1000)
    s = sin(x)

    imf = eemd(s, 1000, 0.2)

    wks = gsn_open_wks("pdf", "eemd")

    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@trXMinF = 0.0
    res@trXMaxF = 2.0*PI
    res@trYMinF = -1.1
    res@trYMaxF = 1.1
    res@tmXBMode = "Manual"
    res@tmXBTickStartF = 0.0
    res@tmXBTickEndF = 2.0*PI
    res@tmXBTickSpacingF = 2.0*PI/4.0
    res@tmYLMode = "Manual"
    res@tmYLTickStartF = -1.1
    res@tmYLTickEndF = 1.1
    res@tmYLTickSpacingF = 0.5
    res@xyLineThicknessF = 3.0
    res@vpWidthF = 24.0
    res@vpHeightF = 4.0

    dims = dimsizes(imf)
    plots = new(dims(0), graphic)

    do i = 0, dims(0)-1
        plots(i) = gsn_csm_xy(wks, x, imf(i,:), res)
    end do

    res_panel = True
    res_panel@gsnMaximize = True
    res_panel@gsnPanelXWhiteSpacePercent = 0.0
    res_panel@gsnPanelYWhiteSpacePercent = 0.0

    gsn_panel(wks, plots, (/dims(0),1/), res_panel)

end
