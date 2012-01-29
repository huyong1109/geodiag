load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$GEODIAG_ROOT/scripts/utils/geodiag_plot_utils.ncl"

; ------------------------------------------------------------------------------
; Drescription:
;
;   This script is used to draw the wavelet analysis of SST at NINO3.4 region.
;
; Input:
;
;   Monthly SST temporal series.
;
; Authors:
;
;   - originally created by Lijuan Li
;   - modified by Ning Hu
;   - standardized by Li Dong
; ------------------------------------------------------------------------------

begin

    if (.not. isdefined("start_year")) then
        report_error("Start year is not provided!")
    end if
    if (.not. isdefined("end_year")) then
        report_error("End year is not provided!")
    end if
    if (.not. isdefined("file_name")) then
        report_error("SST data file is not provided!")
    end if

    f = addfile(file_name, "r")

    if (.not. isfilevar(f, "time")) then
        report_error("There is no time variable in "+file_name+"!")
    end if
    if (isatt(f->time, "units")) then
        dates = ut_calendar(f->time, -2)/100
        use_index = False
    else
        report_warning("There is no time units, "+ \
            "so use input years as index instead.")
        dates = ispan(0, dimsizes(f->time)-1, 1)
        use_index = True
    end if

    if (.not. use_index) then
        start_date = start_year*100+1
        end_date = end_year*100+12
        num_time = 12*(end_year-start_year+1)
    else
        start_date = start_year
        end_date = end_year
        num_time = end_year-start_year+1
    end if
    years = fspan(start_year, end_year, num_time)

    i = ind(dates .eq. start_date)
    j = ind(dates .eq. end_date)

    ; get SST variable
    var_names = get_file_vars(file_name)
    if (dimsizes(var_names) .ne. 1) then
        report_error("There are more than 1 variable in "+file_name+"!")
    end if
    if (dimsizes(dimsizes(f->$var_names(0)$)) .eq. 4) then
        sst = f->$var_names(0)$(i:j,0,:,:)
    end if
    if (dimsizes(dimsizes(f->$var_names(0)$)) .eq. 3) then
        sst = f->$var_names(0)$(i:j,:,:)
    end if
    if (.not. isdefined("sst")) then
        report_error("Unknown dimensions of "+var_names(0)+"!")
    end if

    ; --------------------------------------------------------------------------
    ; calculate nino34 index
    lon_idx = select_region_lon("nino34", f->lon)
    lat_idx = select_region_lat("nino34", f->lat)
    ssta = rmMonAnnCycTLL(sst)
    sstlonave = dim_avg_n_Wrap(ssta(:,lat_idx,lon_idx), 2)
    nino34 = dim_avg_n_Wrap(sstlonave(:,:), 1)

    ; --------------------------------------------------------------------------
    ; calculate wavelet
    N = num_time
    mother   = 0
    param    = 6.0
    dt       = 0.25
    s0       = dt
    dj       = 0.25
    jtot     = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
    npad     = tointeger((tointeger(num_time^0.5)+1)^2)
    nadof    = 0
    noise    = 1
    siglvl   = 0.05
    isigtest = 0
    result   = wavelet(nino34, mother, dt, param, s0, dj, jtot, npad, \
                       noise, isigtest, siglvl, nadof)
    power         = onedtond(result@power, (/jtot,N/))
    power!0       = "period"
    power&period  = result@period
    power!1       = "time"
    power&time    = years
    ; TODO: Clarify the significance.
    sig           = power
    sig           = power/conform(power, result@signif, 0)
    sig@long_name = "Significance"
    sig@units     = " "

    ; --------------------------------------------------------------------------
    ; draw wavelet plot
    wks = gsn_open_wks("pdf", "nino34_wavelet")

    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                      = True
    res@tiXAxisString        = "Year"
    res@tiYAxisString        = "Period"
    res@gsnMaximize          = True
    res@gsnDraw              = False
    res@gsnFrame             = False
    res@cnFillOn             = True
    res@cnFillMode           = "RasterFill"
    res@cnRasterSmoothingOn  = True
    res@cnLinesOn            = False
    res@cnLineLabelsOn       = False
    res@cnInfoLabelOn        = False
    res@gsnSpreadColors      = True
    res@trYReverse           = True
    res@tmYLMode             = "Explicit"
    res@tmXBMode             = "Explicit"
    res@tmYLValues           = (/1,2,3,4,5,8,10/)
    res@tmXBValues           = ispan(start_year, end_year, 10)
    res@tmXBMinorOn          = True
    res@tmXBMinorValues      = ispan(start_year, end_year, 1)
    res@tmYLLabels           = (/"1","2","3","4","5","8","10"/)
    res@tmXBLabels           = tostring(ispan(start_year, end_year, 10))
    res@tmYLLabelFontHeightF = 0.01
    res@tmXBLabelFontHeightF = 0.01
    res@tmLabelAutoStride    = True
    res@vpHeightF            = 0.3
    res@vpWidthF             = 0.8
    res@vpXF                 = 0.1
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = ispan(0, 75, 5)
    res@lbLabelFontHeightF   = 0.015
    res@lbOrientation        = "Vertical"
    res@lbBoxMinorExtentF    = 0.1
    res@pmLabelBarOrthogonalPosF = -0.05

    power&period             = power&period/12.0/dt
    plot = gsn_csm_contour(wks, power({0.5:11.7},:), res)
    delete(res)

    ; -------------------------------------------------------------------------
    ; draw reference line
    x = (/min(years),max(years)/)

    refer_periods = (/2,3,4,5/)
    dum = new(dimsizes(refer_periods), graphic)

    res = True
    res@gsLineDashPattern = 2
    res@gsLineColor       = "blue"
    do i = 0, dimsizes(refer_periods)-1
        y = (/refer_periods(i),refer_periods(i)/)
        dum(i) = gsn_add_polyline(wks, plot, x, y, res)
    end do

    draw(plot)
    frame(wks)

    notice("Figure nino34_wavelet.pdf is generated!")

end
