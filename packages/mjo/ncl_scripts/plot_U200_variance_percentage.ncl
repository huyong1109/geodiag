load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("output_dir")

    output_figure = systemfunc("basename "+dataset+" .nc")

    fin = addfile(dataset, "r")

    U200 = fin->U200

    wks = gsn_open_wks("pdf", output_dir+"/"+output_figure)

    res = True
    res@gsnMaximize = True
    res@gsnPaperOrientation = "portrait"
    res@cnLinesOn = False
    res@cnFillOn = True
    res@mpMinLatF = -30
    res@mpMaxLatF =  30

    plot = gsn_csm_contour_map(wks, U200, res)

    notice("Figure "+output_figure+".pdf is created.")

end
