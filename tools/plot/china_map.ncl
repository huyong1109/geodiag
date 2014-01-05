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
;
; Configuration:
;
;   You can configure the China map plotting by using the following GEODIAG
;   resources before invoking 'setup_china_map':
;
;     - isUseLowResolution: use low resolution (modified by me)
;     - isShowProvince: show province boundaries or not
;     - isShowCity: show city boundaries or not
;     - cityColor: set the color of city boundaries
;     - cityThickness: set the thickness of city boundaries
;     - isShowSouthChinaSea: show South China Sea or not
;     - isAddMask: add mask to show only China region or not
;     - isShowRivers: show first class rivers or not
;     - boundaryColor: set the color of boundary
;     - boundaryThickness: set the thickness of boundary
;     - riverColor: set the color of rivers
;     - riverThickness: set the thickness of rivers
;     - southChinaSeaMapWidth: set the width of the small map
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
;   2013-12-25 - Add city boundary plots.
;   2014-01-05 - Change to use NCL mask.
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

config = True ; global internal configuration

procedure setup_china_map(res)
begin

    res          = True
    res@gsnDraw  = False
    res@gsnFrame = False

    ; --------------------------------------------------------------------------
    ; transfer configuration for GEODIAG from res to internal config variable
    transfer_attribute(res, config, "isUseLowResolution", False)
    transfer_attribute(res, config, "isShowProvince", False)
    transfer_attribute(res, config, "isShowCity", False)
    transfer_attribute(res, config, "cityColor", "blue")
    transfer_attribute(res, config, "cityThickness", 0.5)
    transfer_attribute(res, config, "isShowSouthChinaSea", False)
    transfer_attribute(res, config, "isAddMask", False)
    transfer_attribute(res, config, "isShowRivers", False)
    transfer_attribute(res, config, "riverColor", "black")
    transfer_attribute(res, config, "riverThickness", 0.5)
    transfer_attribute(res, config, "boundaryColor", "black")
    transfer_attribute(res, config, "boundaryThickness", 0.5)
    transfer_attribute(res, config, "southChinaSeaMapWidth", 0.17)

    ; --------------------------------------------------------------------------
    ; set default NCL resources if user does not provide them
    set_default(res, "gsnMaximize", True)
    set_default(res, "mpMinLatF", 17.0)
    set_default(res, "mpMaxLatF", 55.0)
    set_default(res, "mpMinLonF", 72.0)
    set_default(res, "mpMaxLonF", 136.0)
    set_default(res, "mpOutlineOn", False)
    set_default(res, "mpLandFillColor", "white")
    set_default(res, "mpOceanFillColor", "white")
    set_default(res, "mpInlandWaterFillColor", "white")

    if (config@isAddMask) then
        ; suggested in http://bbs.06climate.com/forum.php?mod=viewthread&tid=11797&extra=page%3D1&page=1
        res@cnFillDrawOrder = "PreDraw"
        res@mpDataBaseVersion = "MediumRes"
        res@mpDataSetName = "Earth..4"
        res@mpAreaMaskingOn = True
        res@mpMaskAreaSpecifiers = (/"China","Taiwan", \
              "Disputed area between India and China", \
              "India:Arunachal Pradesh"/)
    end if

end

procedure attach_china_map(wks, base_plot)
local res1, res2, res3, f, small_map, map
begin

    ; ------------------------------------------------------------------------
    ; draw china map from shapefile directly which is downloaded from:
    ;   National Fundamental Geographic Information System
    ;   http://nfgis.nsdi.gov.cn/nfgis/english/default.htm
    if (config@isShowCity) ; when plotting city, also plot province
        config@isShowProvince = True
    end if
    if (config@isShowProvince) then
        china_shp = "$GEODIAG_TOOLS/data/map/bou2_4l.shp"
    else
        if (config@isUseLowResolution) then
            china_shp = "$GEODIAG_TOOLS/data/map/bou1_4l_low.shp"
        else
            china_shp = "$GEODIAG_TOOLS/data/map/bou1_4l.shp"
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
            river_shp = "$GEODIAG_TOOLS/data/map/hyd1_4l_low.shp"
        else
            river_shp = "$GEODIAG_TOOLS/data/map/hyd1_4l.shp"
        end if
        res1@gsLineColor        = config@riverColor
        res1@gsLineThicknessF   = config@riverThickness
        plot_shapefile(wks, base_plot, base_plot, river_shp, res1)
    end if

    ; --------------------------------------------------------------------------
    ; draw city boundaries
    if (config@isShowCity)
        city_shp = "$GEODIAG_TOOLS/data/map/city.shp"
        res1@gsLineColor = config@cityColor
        res1@gsLineThicknessF = config@cityThickness
        plot_shapefile(wks, base_plot, base_plot, city_shp, res1)
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
