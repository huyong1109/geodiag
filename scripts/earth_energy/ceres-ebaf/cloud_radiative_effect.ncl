load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/scripts/utils/geodiag_plot_utils.ncl"

; ------------------------------------------------------------------------------
; Description:
;
;   This script is used to diagnose the cloud radiative effect (shortly as
;   CRE), which is defined as the difference in the top of atmosphere radiation
;   balance between the cloudy and clear-sky atmosphere. And it is different
;   from cloud radiative forcing (Hillman, 2011), but in Oreopoulos et al. 2011,
;   "CRE, also known as cloud radiative forcing". So which one is right?
;
; Note:
;
;   SW CRE ~= clear-sky SW up flux - all-sky SW up flux
;   LW CRE ~= clear-sky LW up flux - all-sky LW up flux
;   LW CRE + SW CRE ~= net CRE
;
; Authors:
;
;   Li Dong - 2012-01-31
; ------------------------------------------------------------------------------

begin

    if (isdefined("data_file_obs")) then
        has_obs_data = True
    else
        has_obs_data = False
    end if

    if (isdefined("data_file_model")) then
        has_model_data = True
    else
        has_model_data = False
    end if

    if (.not. has_obs_data .and. .not. has_model_data) then
        report_error("No observation or model data have been provided!")
    end if

    ; --------------------------------------------------------------------------
    ; open observation data file
    if (has_obs_data) then
        f_obs = addfile(data_file_obs, "r")
    end if

    lon_obs = f_obs->lon
    lat_obs = f_obs->lat

    swcre_obs = f_obs->clim_swcre
    lwcre_obs = f_obs->clim_lwcre

    ; --------------------------------------------------------------------------
    ; open model data file
    if (has_model_data) then
        f_model = addfile(data_file_model, "r")
    end if

    lon_model = f_model->lon
    lat_model = f_model->lat

    swcre_model = clmMonTLL(f_model->SWCF)
    lwcre_model = clmMonTLL(f_model->LWCF)

    swcre_model!0 = "time"
    swcre_model!1 = "lat"
    swcre_model!2 = "lon"
    swcre_model&lat = lat_model
    swcre_model&lon = lon_model

    swcre_model = lonFlip(swcre_model)

    lwcre_model!0 = "time"
    lwcre_model!1 = "lat"
    lwcre_model!2 = "lon"
    lwcre_model&lat = lat_model
    lwcre_model&lon = lon_model

    lwcre_model = lonFlip(lwcre_model)

    lon_model = (/swcre_model&lon/)

    ; --------------------------------------------------------------------------
    ; interpolate observation onto model grids
    swcre_obs_model = linint2_Wrap(lon_obs, lat_obs, swcre_obs, True, \
                                   lon_model, lat_model, 0)
    copy_VarCoords(swcre_model, swcre_obs_model)

    lwcre_obs_model = linint2_Wrap(lon_obs, lat_obs, lwcre_obs, True, \
                                   lon_model, lat_model, 0)
    copy_VarCoords(lwcre_model, lwcre_obs_model)

    ; --------------------------------------------------------------------------
    ; differences
    swcre_diff = swcre_model-swcre_obs_model
    copy_VarCoords(swcre_model, swcre_diff)

    lwcre_diff = lwcre_model-lwcre_obs_model
    copy_VarCoords(lwcre_model, lwcre_diff)

    ; --------------------------------------------------------------------------
    ; plot figures
    wks = gsn_open_wks("pdf", "cloud_radiative_effect")

    gsn_define_colormap(wks, "temp_19lev")

    res = True
    setup_contour(res)

    res@gsnMaximize = True
    res@mpProjection = "Robinson"
    res@mpPerimOn = False
    res@mpGridLineColor = "Background"
    res@mpGridLineThicknessF = 0.001
    res@mpGridAndLimbOn = True
    res@mpGridAndLimbDrawOrder = "PreDraw"

    ; ==========================================================================
    ; shortwave
    ;set_contour_range(res, -120.0, 40.0, 5.0)
    ;res@lbLabelStride = 2

    ;res@gsnLeftString = "GAMIL AMIP control SW cloud radiative forcing"
    ;plot = gsn_csm_contour_map(wks, dim_avg_n_Wrap(swcre_model, 0), res)

    ;frame(wks)

    ;res@gsnLeftString = "CERES-EBAF SW cloud radiative effect"
    ;plot = gsn_csm_contour_map(wks, dim_avg_n_Wrap(swcre_obs_model, 0), res)

    ;frame(wks)

    set_contour_range(res, -40.0, 40.0, 2.5)
    res@lbLabelStride = 4

    diff = month_to_season(swcre_diff, "DJF")
    res@gsnLeftString = "SW DJF: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = month_to_season(swcre_diff, "MAM")
    res@gsnLeftString = "SW MAM: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = month_to_season(swcre_diff, "JJA")
    res@gsnLeftString = "SW JJA: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = month_to_season(swcre_diff, "SON")
    res@gsnLeftString = "SW SON: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = dim_avg_n_Wrap(swcre_diff, 0)
    res@gsnLeftString = "SW ANN: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    ; ==========================================================================
    ; longwave
    ;set_contour_range(res, 0.0, 75.0, 2.5)
    ;res@lbLabelStride = 2

    ;res@gsnLeftString = "GAMIL AMIP control LW cloud radiative forcing"
    ;plot = gsn_csm_contour_map(wks, dim_avg_n_Wrap(lwcre_model, 0), res)

    ;frame(wks)

    ;res@gsnLeftString = "CERES-EBAF LW cloud radiative effect"
    ;plot = gsn_csm_contour_map(wks, dim_avg_n_Wrap(lwcre_obs_model, 0), res)

    ;frame(wks)

    set_contour_range(res, -40.0, 40.0, 2.5)
    res@lbLabelStride = 4

    diff = month_to_season(lwcre_diff, "DJF")
    res@gsnLeftString = "LW DJF: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = month_to_season(lwcre_diff, "MAM")
    res@gsnLeftString = "LW MAM: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = month_to_season(lwcre_diff, "JJA")
    res@gsnLeftString = "LW JJA: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = month_to_season(lwcre_diff, "SON")
    res@gsnLeftString = "LW SON: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

    diff = dim_avg_n_Wrap(lwcre_diff, 0)
    res@gsnLeftString = "LW ANN: GAMIL - CERES-EBAF ("+ \
        sprintf("%.1f", wgt_areaave(diff, 1.0, 1.0, 0))+")"
    res@gsnRightString = "max: "+sprintf("%.1f", max(diff))+" "+ \
                         "min: "+sprintf("%.1f", min(diff))
    plot = gsn_csm_contour_map(wks, diff(0,:,:), res)

    frame(wks)

end
