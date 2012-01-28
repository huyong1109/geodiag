load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

load "$GEODIAG_ROOT/scripts/utils/geodiag_plot_utils.ncl"

begin

    wks = gsn_open_wks("pdf", "china_map")

    ; --------------------------------------------------------------------------
    ; draw any data you want here
    f = addfile("flow.nc", "r")

    res                 = True
    res@cnFillOn        = True
    res@cnLinesOn       = False
    res@gsnSpreadColors = True
    set_china_map(res) ; <--- set the resource for China map
    plot = gsn_csm_contour_map(wks, f->u(0,:,:), res)

    ; --------------------------------------------------------------------------
    ; attach China map on the base plot
    config = True
    config@gdShowProvince = False
    draw_china_map(wks, plot, config)

    frame(wks)

end
