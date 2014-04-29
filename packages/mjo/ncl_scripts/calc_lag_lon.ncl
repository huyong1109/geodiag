load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("refer_dataset")
    check_cmd_arg("var")
    check_cmd_arg("refer_var")
    check_cmd_arg("output")

    fin1 = addfile(dataset, "r")
    fin2 = addfile(refer_dataset, "r")

    max_lag_days = 30
    if (max_lag_days .gt. dimsizes(fin1->time)/4) then
        report_error("calc_lag_lon: Sample number is not sufficient (at least "+(max_lag_days*4)+")!")
    end if

    num_lon = dimsizes(fin1->lon)
    num_lag = 2*max_lag_days+1

    data1 = dim_avg_n_Wrap(fin1->$var$(time|:,{lat|-10:10},lon|:), 1) ; TODO: Should we use area-weighted average function?
    data2 = fin2->$refer_var$

    ccr = new((/num_lon,num_lag/), float)

    do i = 0, num_lon-1
        data1_lead_data2 = esccr(data1(:,i), data2, max_lag_days)
        data2_lead_data1 = esccr(data2, data1(:,i), max_lag_days)
        ccr(i,0:max_lag_days-1) = data1_lead_data2(1:max_lag_days:-1)
        ccr(i,max_lag_days:) = data2_lead_data1(0:max_lag_days)
    end do

    system("rm -f "+output)
    fout = addfile(output, "c")

    setfileoption(fout, "DefineMode", True)

    filedimdef(fout, (/"lon","lag"/), (/num_lon,num_lag/), (/False,False/))

    filevardef(fout, "lon", getfilevartypes(fin1, "lon"), "lon")
    filevarattdef(fout, "lon", fin1->lon)
    filevardef(fout, "lag", "integer", "lag")
    fout->lag@long_name = "lag days"
    filevardef(fout, "ccr", typeof(ccr), (/"lon","lag"/))
    fout->ccr@long_name = "lag-longitude cross correlations upon "+refer_var

    setfileoption(fout, "DefineMode", False)

    fout->lon = (/fin1->lon/)
    fout->lag = (/ispan(-max_lag_days, max_lag_days, 1)/)
    fout->ccr = (/ccr/)

    notice("File "+output+" is created.")

end
