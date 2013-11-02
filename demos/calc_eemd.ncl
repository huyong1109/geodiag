load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    PI = atan(1.0)*4.0
    x = fspan(0.0, 2.0*PI, 100)
    s = sin(x)

    imf = eemd(s, 0.2, 1000)

    wks = gsn_open_wks("pdf", "eemd")

    eemd_plot_imf(wks, x, imf, True)

end
