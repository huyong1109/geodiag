load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_UTILS/geodiag_plot_utils.ncl"

; ------------------------------------------------------------------------------
; Description:
;
;   This script is used to draw the Taylor diagram among observations and among
;   COSP results and observations. All the observations are interpolated onto
;   the model grids before drawing diagrams, and area-weighting is applied to 
;   the data.
;
; Authors:
;
;   Li Dong - 2012-02-15
; ------------------------------------------------------------------------------

; TODO: Refactor the data formats and interfaces!

function get_clt_name(sat_name)
begin

    return "clt"+sat_name

end

function get_clh_name(sat_name)
begin

    return "clh"+sat_name

end

function get_clm_name(sat_name)
begin

    return "clm"+sat_name

end

function get_cll_name(sat_name)
begin

    return "cll"+sat_name

end

begin

    wks = gsn_open_wks("pdf", "cloud_fraction_taylor_diagram")

    sat_names = (/"isccp","modis","calipso"/)

    ; --------------------------------------------------------------------------
    f = addfile("cloud_fraction_annual_cycle.nc", "r")

    lon_model = f->lon
    lat_model = f->lat
    lon_bnds_model = f->lon_bnds
    lat_bnds_model = f->lat_bnds

    clmodel = new((/dimsizes(sat_names),4,12, \
                    dimsizes(lat_model),dimsizes(lon_model)/), float)

    do i = 0, dimsizes(sat_names)-1
        clmodel(i,0,:,:,:) = f->$get_clt_name(sat_names(i))$
        clmodel(i,1,:,:,:) = f->$get_clh_name(sat_names(i))$
        clmodel(i,2,:,:,:) = f->$get_clm_name(sat_names(i))$
        clmodel(i,3,:,:,:) = f->$get_cll_name(sat_names(i))$
    end do

    ; --------------------------------------------------------------------------
    f = addfile("../data/satellite/isccp/cloud_fraction_annual_cycle.nc", "r")

    clisccp_obs = new((/4,12,dimsizes(f->latitude),dimsizes(f->longitude)/), float)
    clisccp_obs(0,:,:,:) = lonFlip(f->cltisccp)
    clisccp_obs(1,:,:,:) = lonFlip(f->clhisccp)
    clisccp_obs(2,:,:,:) = lonFlip(f->clmisccp)
    clisccp_obs(3,:,:,:) = lonFlip(f->cllisccp)

    lat_isccp_obs = clisccp_obs&latitude
    lon_isccp_obs = clisccp_obs&longitude

    ; --------------------------------------------------------------------------
    f = addfile("../data/satellite/modis/cloud_fraction_annual_cycle.nc", "r")

    clmodis_obs = new((/4,12,dimsizes(f->lat),dimsizes(f->lon)/), float)
    clmodis_obs(0,:,:,:) = lonFlip(f->cltmodis)
    clmodis_obs(1,:,:,:) = lonFlip(f->clhmodis)
    clmodis_obs(2,:,:,:) = lonFlip(f->clmmodis)
    clmodis_obs(3,:,:,:) = lonFlip(f->cllmodis)

    lat_modis_obs = clmodis_obs&lat
    lon_modis_obs = clmodis_obs&lon

    ; --------------------------------------------------------------------------
    f = addfile("../data/satellite/calipso/cloud_fraction_annual_cycle.nc", "r")

    clcalipso_obs = new((/4,12,dimsizes(f->latitude),dimsizes(f->longitude)/), float)
    clcalipso_obs(0,:,:,:) = lonFlip(f->cltcalipso)
    clcalipso_obs(1,:,:,:) = lonFlip(f->clhcalipso)
    clcalipso_obs(2,:,:,:) = lonFlip(f->clmcalipso)
    clcalipso_obs(3,:,:,:) = lonFlip(f->cllcalipso)

    lat_calipso_obs = clcalipso_obs&latitude
    lon_calipso_obs = clcalipso_obs&longitude

    ; --------------------------------------------------------------------------
    ; interpolate observations onto model grids
    clobs = new(dimsizes(clmodel), float)
    clobs(0,:,:,:,:) = linint2_Wrap(lon_isccp_obs, lat_isccp_obs, clisccp_obs, \
                                    True, lon_model, lat_model, 0)
    clobs(1,:,:,:,:) = linint2(lon_modis_obs, lat_modis_obs, clmodis_obs, \
                               True, lon_model, lat_model, 0)
    clobs(2,:,:,:,:) = linint2(lon_calipso_obs, lat_calipso_obs, clcalipso_obs, \
                               True, lon_model, lat_model, 0)

    ; --------------------------------------------------------------------------
    ; calculate annual means
    notice("Calculate annual means for model and observation.")
    clmodel_ann = dim_avg_n_Wrap(clmodel, 2)
    clobs_ann = dim_avg_n_Wrap(clobs, 2)

    ; --------------------------------------------------------------------------
    ; area weights
    lat_idx = ind(lat_model .ge. -60.0 .and. lat_model .le. 60.0)
    wgt = new((/dimsizes(lat_idx),dimsizes(lon_model)/), float)
    
    do j = lat_idx(0), lat_idx(dimsizes(lat_idx)-1)
        wgt(j-lat_idx(0),:) = cos(lat_model(j)*3.1415926/180.0)
    end do

    ; --------------------------------------------------------------------------
    ; statistics
    avg_obs = new((/dimsizes(sat_names),4/), float)
    sd_obs = new(dimsizes(avg_obs), float)
    avg_model = new(dimsizes(avg_obs), float)
    sd_model = new(dimsizes(avg_obs), float)

    do i = 0, dimsizes(sat_names)-1
        do j = 0, 3
            N = num(.not. ismissing(clobs_ann(i,j,lat_idx,:)))
            avg_obs(i,j) = wgt_areaave2(clobs_ann(i,j,lat_idx,:), wgt, 0)
            sd_obs(i,j) = sqrt(wgt_areasum2((clobs_ann(i,j,lat_idx,:)-avg_obs(i,j))^2, wgt, 0)/N)
            N = num(.not. ismissing(clmodel_ann(i,j,lat_idx,:)))
            avg_model(i,j) = wgt_areaave2(clmodel_ann(i,j,lat_idx,:), wgt, 0)
            sd_model(i,j) = sqrt(wgt_areasum2((clmodel_ann(i,j,lat_idx,:)-avg_model(i,j))^2, wgt, 0)/N)
        end do
    end do

    ; --------------------------------------------------------------------------
    ; observation vs observation
    ccor1 = new((/dimsizes(sat_names)-1,4/), float)
    sdratio1 = new(dimsizes(ccor1), float)

    ; use the first satellite as the reference
    do i = 1, dimsizes(sat_names)-1
        do j = 0, 3
            N = num(.not. ismissing(clobs_ann(i,j,lat_idx,:)) .and. \
                    .not. ismissing(clobs_ann(0,j,lat_idx,:)))
            ccor1(i-1,j) = wgt_areasum2((clobs_ann(i,j,lat_idx,:)-avg_obs(i,j))* \
                                        (clobs_ann(0,j,lat_idx,:)-avg_obs(0,j)), \
                                        wgt, 0)/N/sd_obs(i,j)/sd_obs(0,j)
            sdratio1(i-1,j) = sd_obs(i,j)/sd_obs(0,j)
        end do
    end do

    res1 = True
    res1@tiMainString = "MODIS/CALIPSO vs ISCCP"
    res1@taylorDraw = False
    res1@taylorFrame = False
    res1@caseLabels = str_upper(sat_names(1:dimsizes(sat_names)-1))
    res1@Colors = (/"red","blue"/)
    res1@varLabels = (/"Total cloud fraction","High cloud fraction","Middle cloud fraction","Low cloud fraction"/)
    res1@varLabelsYloc = 1.4
    res1@ccRays = (/min(ccor1),max(ccor1)/)
    res1@gsMarkerThicknessF = 3.0

    plot1 = taylor_diagram(wks, sdratio1, ccor1, res1)

    ; --------------------------------------------------------------------------
    ; observation vs simulator
    ccor2 = new((/dimsizes(sat_names),4/), float)
    sdratio2 = new(dimsizes(ccor2), float)

    do i = 0, dimsizes(sat_names)-1
        do j = 0, 3
            N = num(.not. ismissing(clmodel_ann(i,j,lat_idx,:)) .and. \
                    .not. ismissing(clobs_ann(i,j,lat_idx,:)))
            ccor2(i,j) = wgt_areasum2((clmodel_ann(i,j,lat_idx,:)-avg_model(i,j))* \
                                      (clobs_ann(i,j,lat_idx,:)-avg_obs(i,j)), \
                                        wgt, 0)/N/sd_model(i,j)/sd_obs(i,j)
            sdratio2(i,j) = sd_model(i,j)/sd_obs(i,j)
        end do
    end do

    res2 = True
    res2@tiMainString = "Observation vs Simulator"
    res2@taylorDraw = False
    res2@taylorFrame = False
    res2@caseLabels = str_upper(sat_names)
    res2@Colors = (/"black","red","blue"/)
    res2@varLabels = (/"Total cloud fraction","High cloud fraction","Middle cloud fraction","Low cloud fraction"/)
    res2@varLabelsYloc = 1.4
    res2@ccRays = (/min(ccor2),max(ccor2)/)
    res2@gsMarkerThicknessF = 3.0

    plot2 = taylor_diagram(wks, sdratio2, ccor2, res2)

    ; --------------------------------------------------------------------------
    ; draw them on a panel
    pres = True
    pres@gsnMaximize = True
    pres@gsnPanelFigureStringsPerimOn = False
    pres@gsnPanelFigureStrings = (/"(a)","(b)"/)
    pres@amOrthogonalPosF = -0.5
    pres@amParallelPosF = -0.5
    gsn_panel(wks, (/plot1,plot2/), (/1,2/), pres)

end
