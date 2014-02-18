load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("output")

    fin = addfile(dataset, "r")

    spec = specx_anal(fin->$var$, 0, 7, 0.1)
    splt = specx_ci(spec, 0.05, 0.95)

    system("rm -f "+output)
    fout = addfile(output, "c")

    fout->spec = spec
    fout->splt = splt

    notice("File "+output+" is created.")

end
