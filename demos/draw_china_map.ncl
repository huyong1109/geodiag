load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

load "$GEODIAG_ROOT/scripts/utils/geodiag_plot_utils.ncl"

begin

    wks = gsn_open_wks("pdf", "china_map")

    map = draw_china_map(wks, False)

    frame(wks)

end
