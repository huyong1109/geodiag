load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_UTILS/geodiag_plot_utils.ncl"

; ------------------------------------------------------------------------------
; Drescription:
;
;   This script is used to draw the cloud fractions (total/high/mid/low) from
;   several observations and their corresponding instrument simulators (COSP).
;
; Authors:
;
;   Li Dong - 2012-02-14
; ------------------------------------------------------------------------------

; TODO: Refactor the data formats and interfaces!

function draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)
local plots
begin

    plots = new(4, graphic)

    tmp = dim_avg_n_Wrap(clt, 0)
    res@gsnLeftString = "ANN: "+clt@long_name
    res@gsnRightString = sprintf("avg: %4.1f", wgt_areaave(tmp, wgt, 1.0, 0))+"%"
    plots(0) = gsn_csm_contour_map(wks, tmp, res)

    tmp = dim_avg_n_Wrap(clh, 0)
    res@gsnLeftString = "ANN: "+clh@long_name
    res@gsnRightString = sprintf("avg: %4.1f", wgt_areaave(tmp, wgt, 1.0, 0))+"%"
    plots(1) = gsn_csm_contour_map(wks, tmp, res)

    tmp = dim_avg_n_Wrap(clm, 0)
    res@gsnLeftString = "ANN: "+clm@long_name
    res@gsnRightString = sprintf("avg: %4.1f", wgt_areaave(tmp, wgt, 1.0, 0))+"%"
    plots(2) = gsn_csm_contour_map(wks, tmp, res)

    tmp = dim_avg_n_Wrap(cll, 0)
    res@gsnLeftString = "ANN: "+cll@long_name
    res@gsnRightString = sprintf("avg: %4.1f", wgt_areaave(tmp, wgt, 1.0, 0))+"%"
    plots(3) = gsn_csm_contour_map(wks, tmp, res)

    return plots

end

begin

    ; --------------------------------------------------------------------------
    ; setup resources for plotting
    wks = gsn_open_wks("pdf", "cloud_fraction")

    gsn_define_colormap(wks, "WhiteBlueGreenYellowRed")

    res = True
    setup_contour(res)
    res@cnFillMode = "RasterFill"

    res@gsnDraw = False
    res@lbLabelBarOn = False

    set_contour_range(res, 0.0, 100.0, 1.0)

    ; --------------------------------------------------------------------------
    ; open simulator data file
    f = addfile("cloud_fraction_annual_cycle.nc", "r")

    wgt = cos(f->lat*3.1415926/180.0)

    ; --------------------------------------------------------------------------
    ; ISCCP simulator results
    clt = f->cltisccp
    clh = f->clhisccp
    clm = f->clmisccp
    cll = f->cllisccp

    clt@long_name = "Simulated ISCCP total cloud fraction"
    clh@long_name = "Simulated ISCCP high cloud fraction"
    clm@long_name = "Simulated ISCCP middle cloud fraction"
    cll@long_name = "Simulated ISCCP low cloud fraction"

    plots_isccp_sim = draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)

    ; --------------------------------------------------------------------------
    ; MODIS simulator results
    clt = f->cltmodis
    clh = f->clhmodis
    clm = f->clmmodis
    cll = f->cllmodis

    clt@long_name = "Simulated MODIS total cloud fraction"
    clh@long_name = "Simulated MODIS high cloud fraction"
    clm@long_name = "Simulated MODIS middle cloud fraction"
    cll@long_name = "Simulated MODIS low cloud fraction"

    plots_modis_sim = draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)

    ; --------------------------------------------------------------------------
    ; CALIPSO simulator results
    clt = f->cltlidarradar
    clh = f->clhcalipso
    clm = f->clmcalipso
    cll = f->cllcalipso

    clt@long_name = "Simulated CALIPSO total cloud fraction"
    clh@long_name = "Simulated CALIPSO high cloud fraction"
    clm@long_name = "Simulated CALIPSO middle cloud fraction"
    cll@long_name = "Simulated CALIPSO low cloud fraction"

    plots_calipso_sim = draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)

    delete(wgt)
    delete(clt)
    delete(clh)
    delete(clm)
    delete(cll)

    ; --------------------------------------------------------------------------
    ; ISCCP observation
    f = addfile("../data/satellite/isccp/cloud_fraction_annual_cycle.nc", "r")

    wgt = cos(f->latitude*3.1415926/180.0)

    clt = f->cltisccp
    clh = f->clhisccp
    clm = f->clmisccp
    cll = f->cllisccp

    clt@long_name = "Observed ISCCP total cloud fraction"
    clh@long_name = "Observed ISCCP high cloud fraction"
    clm@long_name = "Observed ISCCP middle cloud fraction"
    cll@long_name = "Observed ISCCP low cloud fraction"

    plots_isccp_obs = draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)

    delete(wgt)
    delete(clt)
    delete(clh)
    delete(clm)
    delete(cll)

    ; --------------------------------------------------------------------------
    ; MODIS observation
    f = addfile("../data/satellite/modis/cloud_fraction_annual_cycle.nc", "r")

    wgt = cos(f->lat*3.1415926/180.0)

    clt = f->cltmodis
    clh = f->clhmodis
    clm = f->clmmodis
    cll = f->cllmodis

    clt@long_name = "Observed MODIS total cloud fraction"
    clh@long_name = "Observed MODIS high cloud fraction"
    clm@long_name = "Observed MODIS middle cloud fraction"
    cll@long_name = "Observed MODIS low cloud fraction"

    plots_modis_obs = draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)

    delete(wgt)
    delete(clt)
    delete(clh)
    delete(clm)
    delete(cll)

    ; --------------------------------------------------------------------------
    ; CALIPSO observation
    f = addfile("../data/satellite/calipso/cloud_fraction_annual_cycle.nc", "r")

    wgt = cos(f->latitude*3.1415926/180.0)

    clt = f->cltcalipso
    clh = f->clhcalipso
    clm = f->clmcalipso
    cll = f->cllcalipso

    clt@long_name = "Observed CALIPSO total cloud fraction"
    clh@long_name = "Observed CALIPSO high cloud fraction"
    clm@long_name = "Observed CALIPSO middle cloud fraction"
    cll@long_name = "Observed CALIPSO low cloud fraction"

    plots_calipso_obs = draw_cloud_fraction(wks, res, wgt, clt, clh, clm, cll)

    delete(wgt)
    delete(clt)
    delete(clh)
    delete(clm)
    delete(cll)

    ; --------------------------------------------------------------------------
    pres = True
    pres@gsnPanelLabelBar = True
    pres@lbLabelStride = 20
    pres@lbBoxLinesOn = False

    ; --------------------------------------------------------------------------
    ; total cloud fraction panel
    do i = 0, 3
        gsn_panel(wks, (/plots_isccp_obs(i),plots_isccp_sim(i), \
                         plots_modis_obs(i),plots_modis_sim(i), \
                         plots_calipso_obs(i),plots_calipso_sim(i)/), \
                  (/3,2/), pres)
    end do

end
