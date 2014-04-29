load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("num_eof")

    print(dataset)
    fin = addfile(dataset, "r")

    print("check")
    data = fin->$var$(lat|:,lon|:,time|:)
    print("check")

    opt_eof = True
    eof = eofunc_Wrap(data, num_eof, opt_eof)
    opt_eof_ts = True
    eof_ts = eofunc_ts_Wrap(data, eof, opt_eof_ts)

    printVarSummary(eof)
    printVarSummary(eof_ts)

end
