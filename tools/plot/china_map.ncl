; ------------------------------------------------------------------------------
; Description:
;
;   The following two procedures are used to set resource of the external
;   plotting and draw China map on it. The following blogs are refered:
;
;     http://bbs.sciencenet.cn/home.php?mod=space&uid=428536&do=blog&id=308001
;     http://blog.sciencenet.cn/home.php?mod=space&uid=428536&do=blog&id=308032
;
; Input:
;
;   - res: external plotting's resource
;   - wks: a workspace
;   - base_plot: the external plotting
;   - config: configuration
;     config@isUseLowResolution: use low resolution (modified by me)
;     config@isShowProvince: show province boundaries or not
;     config@isShowSouthChinaSea: show South China Sea or not
;     config@isAddMask: add mask to show only China region or not
;     config@isShowRivers: show first class rivers or not
;     config@boundaryColor: set the color of boundary
;     config@boundaryThickness: set the thickness of boundary
;     config@riverColor: set the color of rivers
;     config@riverThickness: set the thickness of rivers
;     config@southChinaSeaMapWidth: set the width of the small map
;
; Authors:
;
;   Li Dong - 2012-01-27
;
; Organization:
;
;   This work is supported by LASG/IAP (http://www.lasg.ac.cn/).
;
; Release note:
;
;   2012-01-27 - First release.
;   2012-02-17 - Add mask for plotting only China region.
;   2012-02-23 - Add option for plotting first class rivers
;   2012-03-15 - Add control on the thickness and color of the boundary
;                and rivers.
;   2013-01-28 - Add the control on the South China Sea small map.
;   2013-12-10 - Add isUseLowResolution option to speed up plotting.
; ------------------------------------------------------------------------------

procedure plot_shapefile(wks, base_plot, attach_plot, shapefile, res)
begin

    f = addfile(shapefile, "r")

    segments = f->segments
    geometry = f->geometry
    segsDims = dimsizes(f->segments)
    geomDims = dimsizes(f->geometry)

    geom_segIndex = f@geom_segIndex
    geom_numSegs  = f@geom_numSegs
    segs_xyzIndex = f@segs_xyzIndex
    segs_numPnts  = f@segs_numPnts
    numFeatures   = geomDims(0)

    lon = f->x
    lat = f->y

    segNum = 0
    do i = 0, numFeatures-1
        start_seg = geometry(i, geom_segIndex)
        num_seg = geometry(i, geom_numSegs)
        do seg = start_seg, start_seg+num_seg-1
            start_point = segments(seg, segs_xyzIndex)
            end_point = start_point+segments(seg, segs_numPnts)-1
            base_plot@$unique_string("china_map")$ = \
                gsn_add_polyline(wks, attach_plot, \
                lon(start_point:end_point), lat(start_point:end_point), res)
            segNum = segNum+1
        end do
    end do

end

procedure setup_china_map(res)
begin

    res                         = True
    res@gsnMaximize             = True
    res@gsnDraw                 = False
    res@gsnFrame                = False
    res@mpMinLatF               = 17.
    res@mpMaxLatF               = 55.
    res@mpMinLonF               = 72.
    res@mpMaxLonF               = 136.
    res@mpOutlineOn             = False
    res@mpLandFillColor         = "white"
    res@mpOceanFillColor        = "white"
    res@mpInlandWaterFillColor  = "white"

end

procedure attach_china_map(wks, base_plot, config)
local res1, res2, res3, f, small_map, map
begin

    ; ------------------------------------------------------------------------
    ; set default configuration
    set_default(config, "isUseLowResolution", False)
    set_default(config, "isShowProvince", False)
    set_default(config, "isShowSouthChinaSea", False)
    set_default(config, "isAddMask", False)
    set_default(config, "isShowRivers", False)
    set_default(config, "riverColor", "black")
    set_default(config, "riverThickness", 0.5)
    set_default(config, "boundaryColor", "black")
    set_default(config, "boundaryThickness", 0.5)
    set_default(config, "southChinaSeaMapWidth", 0.17)

    ; ------------------------------------------------------------------------
    ; draw china map from shapefile directly which is downloaded from:
    ;   National Fundamental Geographic Information System
    ;   http://nfgis.nsdi.gov.cn/nfgis/english/default.htm
    if (config@isShowProvince) then
        china_shp = systemfunc("echo $GEODIAG_TOOLS/data/map/bou2_4l.shp")
    else
        if (config@isUseLowResolution) then
            china_shp = systemfunc("echo $GEODIAG_TOOLS/data/map/bou1_4l_low.shp")
        else
            china_shp = systemfunc("echo $GEODIAG_TOOLS/data/map/bou1_4l.shp")
        end if
    end if
    res1                    = True
    res1@gsLineColor        = config@boundaryColor
    res1@gsLineThicknessF   = config@boundaryThickness
    plot_shapefile(wks, base_plot, base_plot, china_shp, res1)

    ; --------------------------------------------------------------------------
    ; draw rivers
    if (config@isShowRivers) then
        if (config@isUseLowResolution) then
            river_shp = systemfunc("echo $GEODIAG_TOOLS/data/map/hyd1_4l_low.shp")
        else
            river_shp = systemfunc("echo $GEODIAG_TOOLS/data/map/hyd1_4l.shp")
        end if
        res1@gsLineColor        = config@riverColor
        res1@gsLineThicknessF   = config@riverThickness
        plot_shapefile(wks, base_plot, base_plot, river_shp, res1)
    end if


    ; --------------------------------------------------------------------------
    ; draw mask for plotting China only
    if (config@isAddMask) then
        mask_file = systemfunc("echo $GEODIAG_TOOLS/data/map/china_mask.nc")
        f = addfile(mask_file, "r")

        res2                 = True
        res2@gsnDraw         = False
        res2@gsnFrame        = False
        res2@cnFillOn        = True
        res2@cnLinesOn       = False
        res2@cnLineLabelsOn  = False
        res2@lbLabelBarOn    = False
        res2@cnInfoLabelOn   = False
        res2@cnFillColors    = (/"white","white","transparent","transparent"/)
        res2@cnLevelSelectionMode = "ManualLevels"
        res2@cnMinLevelValF  = 0.0
        res2@cnMaxLevelValF  = 1.0
        res2@cnLevelSpacingF = 0.5

        base_plot@mask_plot = gsn_csm_contour(wks, f->china_mask(lat|:,lon|:), res2)

        overlay(base_plot, base_plot@mask_plot)
    end if

    ; --------------------------------------------------------------------------
    ; draw South China Sea area
    if (config@isShowSouthChinaSea) then
        res3                        = True
        res3@gsnDraw                = False
        res3@gsnFrame               = False
        res3@mpMinLatF              = 2.0
        res3@mpMaxLatF              = 23.5
        res3@mpMinLonF              = 105.0
        res3@mpMaxLonF              = 123.0
        res3@vpWidthF               = config@southChinaSeaMapWidth
        res3@mpLandFillColor        = "white"
        res3@mpOceanFillColor       = "white"
        res3@mpInlandWaterFillColor = "white"
        res3@tmXBOn                 = False
        res3@tmYLOn                 = False
        res3@tmXTOn                 = False
        res3@tmYROn                 = False

        small_map = gsn_csm_map(wks, res3)

        res1@gsLineColor            = config@boundaryColor
        res1@gsLineThicknessF       = config@boundaryThickness
        plot_shapefile(wks, base_plot, small_map, china_shp, res1)

        res4                    = True
        res4@amParallelPosF     = 0.495
        res4@amOrthogonalPosF   = 0.495
        res4@amJust             = "BottomRight"

        map = gsn_add_annotation(base_plot, small_map, res4)
    end if

end
