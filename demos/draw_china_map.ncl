load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_UTILS/geodiag_plot_utils.ncl"

begin

    wks = gsn_open_wks("pdf", "china_map")

    res = True
    setup_china_map(res) ; <--- set the resource for China map

    ; --------------------------------------------------------------------------
    ; draw any data you want here
    if (isdefined("data_file")) then
        ; TODO: modify the following for your need
        f = addfile(data_file, "r")

        res@cnFillOn        = True
        res@cnLinesOn       = False
        res@gsnSpreadColors = True
        res@lbLabelBarOn    = False
        res@cnLineLabelsOn  = False

        var_names = get_file_var_names(f)
        print(var_names)

        plot = gsn_csm_contour_map(wks, f->$var_names(12)$(0,:,:), res)
    else
        plot = gsn_csm_map(wks, res)
    end if

    ; --------------------------------------------------------------------------
    ; attach China map on the base plot
    config = True
    config@isShowProvince = False
    config@isShowSouthChinaSea = True
    config@isAddMask = True
    config@isShowRivers = True
    attach_china_map(wks, plot, config)
    draw(plot)

    frame(wks)

end
