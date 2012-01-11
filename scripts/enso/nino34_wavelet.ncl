load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; ------------------------------------------------------------------------------
; Drescription:
;
;   This script is used to draw the wavelet analysis of SST at NINO3.4 region.
; ------------------------------------------------------------------------------

begin

    if (.not. isdefined("start_date")) then
        system("echo [Error]: Start year is not provided!")
        exit
    end if
    if (.not. isdefined("end_date")) then
        system("echo [Error]: End year is not provided!")
        exit
    end if
    if (.not. isdefined("file_name")) then
        system("echo [Error]: SST data file is not provided!")
        exit
    end if

    start_year = start_date/100
    end_year = end_date/100
    num_time = 12*(end_year-start_year+1)

    f = addfile(file_name, "r")

    dates = ut_calendar(f->time, -2)/100
    printVarSummary(YM)

    i = ind(dates .eq. start_date)
    j = ind(dates .eq. end_date)

    sst = f->ts(i:j,0,:,:)

    ; --------------------------------------------------------------------------
    ; calculate nino34 index
    ssta = rmMonAnnCycTLL(sst)
    sstlonave = dim_avg_n_Wrap(ssta(:,{-5:5},{190:240}),2)
    nino34 = dim_avg_n_Wrap(sstlonave(:,{-5:5}),1)
    time = fspan(start_year,end_year,ntimes)

    ; --------------------------------------------------------------------------
    ; calculate wavelet
    N = ntimes
    mother   = 0
    param    = 6.0
    dt       = 0.25
    s0       = dt
    dj       = 0.25
    jtot     = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
    npad     = tointeger( (tointeger(ntimes^0.5)+1)^2)
    nadof    = 0
    noise    = 1
    siglvl   = 0.05
    isigtest = 0
    w        = wavelet(nino34, mother, dt, param, s0, dj, jtot, npad, \
                       noise, isigtest, siglvl, nadof)
    power    = onedtond(w@power,(/jtot,N/))
    power!0          = "period"                        ; Y axis
    power&period     = w@period
    power!1          = "time"                          ; X axis
    power&time       = time
    SIG              = power                            ; transfer meta data
    SIG              = power/conform (power,w@signif,0)
    SIG@long_name    = "Significance"
    SIG@units        = " "

    ; --------------------------------------------------------------------------
    ; draw wavelet plot
    wks = gsn_open_wks("pdf","wavelet")

    gsn_define_colormap(wks, "wh-bl-gr-ye-re")

    res                      = True
    res@tiXAxisString        = "Year"
    res@tiYAxisString        = "Period"
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
    res@tmXBValues           = ispan(1874, 2004, 10)
    res@tmXBMinorOn          = True
    res@tmXBMinorValues      = ispan(1870,2006,1)
    res@tmYLLabels           = (/"1","2","3","4","5","8","10"/)
    res@tmXBLabels           = tostring(ispan(1874,2004,10))
    res@tmYLDataBottomF      = 10
    res@tmYLLabelFontHeightF = 0.01
    res@tmXBLabelFontHeightF = 0.01
    res@tmLabelAutoStride    = True
    res@vpHeightF            = 0.3
    res@vpWidthF             = 0.8
    res@vpXF                 = 0.1
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = ispan(0, 75, 5)
    res@lbLabelFontHeightF   = 0.015
  
    power&period             = power&period/12.0/dt
    plot = gsn_csm_contour(wks, power({0.5:11.7},:), res)
    delete(res)

    ; -------------------------------------------------------------------------
    ; draw reference line
    plx = (/min(time),max(time)/)

    yvalues = (/2,3,4,5/)
    nvalues = dimsizes(yvalues)

    dum = new(nvalues, graphic)

    res = True
    do i=0,nvalues-1
        res@gsLineDashPattern = 2
        res@gsLineColor       = "blue"
        ply = (/yvalues(i),yvalues(i)/)
        dum(i) = gsn_add_polyline(wks, plot, plx, ply, res)
    end do

    draw(plot)
    frame(wks)

end
