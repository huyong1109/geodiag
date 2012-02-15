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
;     config@isShowProvince: show province boundaries or not
;     config@isShowSouthChinaSea: show South China Sea or not
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
; ------------------------------------------------------------------------------

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
    if (.not. isatt(config, "isShowProvince")) then
        config@isShowProvince = False
    end if
    if (.not. isatt(config, "isShowSouthChinaSea")) then
        config@isShowSouthChinaSea = False
    end if

    ; ------------------------------------------------------------------------
    ; draw china map from shapefile directly which is downloaded from:
    ;   National Fundamental Geographic Information System
    ;   http://nfgis.nsdi.gov.cn/nfgis/english/default.htm
    if (config@isShowProvince) then
        shapefile = systemfunc("echo $GEODIAG_UTILS/map/bou2_4l.shp")
    else
        shapefile = systemfunc("echo $GEODIAG_UTILS/map/bou1_4l.shp")
    end if
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

    res1                    = True
    res1@gsLineColor        = "black"
    res1@gsLineThicknessF   = 0.5

    plot1 = new(segsDims(0), graphic)
    segNum = 0
    do i = 0, numFeatures-1
        start_seg = geometry(i, geom_segIndex)
        num_seg = geometry(i, geom_numSegs)
        do seg = start_seg, start_seg+num_seg-1
            start_point = segments(seg, segs_xyzIndex)
            end_point = start_point+segments(seg, segs_numPnts)-1
            base_plot@$unique_string("china_map")$ = \
                gsn_add_polyline(wks, base_plot, \
                lon(start_point:end_point), lat(start_point:end_point), res1)
            segNum = segNum+1
        end do
    end do

    ; --------------------------------------------------------------------------
    ; draw south sea area
    if (config@isShowSouthChinaSea) then
        res2                        = True
        res2@gsnDraw                = False
        res2@gsnFrame               = False
        res2@mpMinLatF              = 2.0
        res2@mpMaxLatF              = 23.5
        res2@mpMinLonF              = 105.0
        res2@mpMaxLonF              = 123.0
        res2@vpHeightF              = 0.17
        res2@vpWidthF               = 0.17
        res2@mpLandFillColor        = "white"
        res2@mpOceanFillColor       = "white"
        res2@mpInlandWaterFillColor = "white"
        res2@tmXBOn                 = False
        res2@tmYLOn                 = False
        res2@tmXTOn                 = False
        res2@tmYROn                 = False

        small_map = gsn_csm_map(wks, res2)

        plot2 = new(segsDims(0), graphic)
        segNum = 0
        do i = 0, numFeatures-1
            start_seg = geometry(i, geom_segIndex)
            num_seg = geometry(i, geom_numSegs)
            do seg = start_seg, start_seg+num_seg-1
                start_point = segments(seg, segs_xyzIndex)
                end_point = start_point+segments(seg, segs_numPnts)-1
                base_plot@$unique_string("china_map")$ = \
                    gsn_add_polyline(wks, small_map, \
                    lon(start_point:end_point), lat(start_point:end_point), res1)
                segNum = segNum+1
            end do
        end do

        res3                    = True
        res3@amParallelPosF     = 0.495
        res3@amOrthogonalPosF   = 0.495
        res3@amJust             = "BottomRight"

        map = gsn_add_annotation(base_plot, small_map, res3)
    end if

end
