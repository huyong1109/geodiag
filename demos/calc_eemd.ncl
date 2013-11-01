load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    PI = atan(1.0)*4.0
    x = fspan(0.0, 2.0*PI, 100)
    s = sin(x)

    imf = eemd(s, 0.0, 1000)

    wks = gsn_open_wks("pdf", "eemd")

    res = True
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
    eemd_plot_imf(wks, x, imf, res)

end
