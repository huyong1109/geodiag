; ------------------------------------------------------------------------------
; Description:
;
;   The following scripts are used to setup basic resources for plotting.
;
; Authors:
;
;   Li Dong - 2012-01-31
; ------------------------------------------------------------------------------

procedure set_default(res, att_name, default)
begin

    if (.not. isatt(res, att_name)) then
        res@$att_name$ = default
    end if

end

procedure setup_contour(res)
begin

    set_default(res, "gsnFrame", False)
    set_default(res, "mpCenterLonF", 180.0)
    set_default(res, "cnFillOn", True)
    set_default(res, "cnLinesOn", False)
    set_default(res, "cnLineLabelsOn", False)
    set_default(res, "gsnSpreadColors", True)

end

procedure set_contour_range(res, min_value, max_value, stride)
begin

    res@cnLevelSelectionMode    = "ManualLevels"
    res@cnMinLevelValF          = min_value
    res@cnMaxLevelValF          = max_value
    res@cnLevelSpacingF         = stride

end

procedure setup_xy(res, x_axis_name, x_axis_coord, y_axis_name, y_axis_coord)
begin

    set_default(res, "gsnFrame", False)
    set_default(res, "gsnMaximize", True)
    set_default(res, "tiXAxisString", x_axis_name)
    if (dimsizes(x_axis_coord) .eq. 3) then
        set_default(res, "tmXBMode", "Manual")
        set_default(res, "tmXBTickStartF", x_axis_coord(0))
        set_default(res, "tmXBTickEndF", x_axis_coord(1))
        set_default(res, "tmXBTickSpacingF", x_axis_coord(2))
        set_default(res, "trXMinF", x_axis_coord(0))
        set_default(res, "trXMaxF", x_axis_coord(1))
    else
        set_default(res, "tmXBMode", "Explicit")
        set_default(res, "tmXBValues", x_axis_coord)
        set_default(res, "tmXBLabels", x_axis_coord)
        set_default(res, "xyXStyle", "Irregular")
        set_default(res, "xyXIrregularPoints", x_axis_coord)
        set_default(res, "trXMinF", x_axis_coord(0))
        set_default(res, "trXMaxF", x_axis_coord(dimsizes(x_axis_coord)-1))
    end if
    set_default(res, "tiYAxisString", y_axis_name)
    if (dimsizes(y_axis_coord) .eq. 3) then
        set_default(res, "tmYLMode", "Manual")
        set_default(res, "tmYLTickStartF", y_axis_coord(0))
        set_default(res, "tmYLTickEndF", y_axis_coord(1))
        set_default(res, "tmYLTickSpacingF", y_axis_coord(2))
        set_default(res, "trYMinF", y_axis_coord(0))
        set_default(res, "trYMaxF", y_axis_coord(1))
    else
        set_default(res, "tmYLMode", "Explicit")
        set_default(res, "tmYLValues", y_axis_coord)
        set_default(res, "tmYLLabels", y_axis_coord)
        set_default(res, "xyYStyle", "Irregular")
        set_default(res, "xyYIrregularPoints", y_axis_coord)
        set_default(res, "trYMinF", y_axis_coord(0))
        set_default(res, "trYMaxF", y_axis_coord(dimsizes(y_axis_coord)-1))
    end if

end
