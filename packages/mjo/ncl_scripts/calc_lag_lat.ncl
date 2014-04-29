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
        report_error("calc_lag_lat: Sample number is not sufficient (at least "+(max_lag_days*4)+")!")
    end if

    num_lat = dimsizes(fin1->lat({-30:30}))
    num_lag = 2*max_lag_days+1

    data1 = dim_avg_n_Wrap(fin1->$var$(time|:,{lat|-30:30},{lon|80:100}), 2)
    data2 = fin2->$refer_var$

    ccr = new((/num_lat,num_lag/), float)

    do j = 0, num_lat-1
        data1_lead_data2 = esccr(data1(:,j), data2, max_lag_days)
        data2_lead_data1 = esccr(data2, data1(:,j), max_lag_days)
        ccr(j,0:max_lag_days-1) = data1_lead_data2(1:max_lag_days:-1)
        ccr(j,max_lag_days:) = data2_lead_data1(0:max_lag_days)
    end do

    system("rm -f "+output)
    fout = addfile(output, "c")

    setfileoption(fout, "DefineMode", True)

    filedimdef(fout, (/"lat","lag"/), (/num_lat,num_lag/), (/False,False/))

    filevardef(fout, "lat", getfilevartypes(fin1, "lat"), "lat")
    filevarattdef(fout, "lat", fin1->lat)
    filevardef(fout, "lag", "integer", "lag")
    fout->lag@long_name = "lag days"
    filevardef(fout, "ccr", typeof(ccr), (/"lat","lag"/))
    fout->ccr@long_name = "lag-latitude cross correlations upon "+refer_var

    setfileoption(fout, "DefineMode", False)

    fout->lat = (/fin1->lat({-30:30})/)
    fout->lag = (/ispan(-max_lag_days, max_lag_days, 1)/)
    fout->ccr = (/ccr/)

    notice("File "+output+" is created.")

end
