load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("num_eof")
    check_cmd_arg("output")

    fin = addfile(dataset, "r")

    lat = fin->lat
    lat_idx = ind(lat .ge. -30.0 .and. lat .le. 30.0)

    tmp = fin->$var$ ; this is more efficient than directly assign to 'data'
    data = tmp({lat|lat_idx},lon|:,time|:)

    ; weight the data
    lat_bnds = calc_lat_bnds(lat)
    lat_wgts = calc_lat_wgts(lat_bnds)
    do j = 0, dimsizes(lat_idx)-1
        data(j,:,:) = data(j,:,:)*doubletofloat(lat_wgts(lat_idx(j)))
    end do

    opt_eof = True
    eof = eofunc_Wrap(data, num_eof, opt_eof)
    opt_eof_ts = True
    eof_ts = eofunc_ts_Wrap(data, eof, opt_eof_ts)

    ; output data
    system("rm -f "+output)
    fout = addfile(output, "c")

    setfileoption(fout, "DefineMode", True)

    num_time = dimsizes(fin->time)
    num_lat = dimsizes(lat_idx)
    num_lon = dimsizes(fin->lon)

    dim_names = (/"time","lat","lon","evn"/)
    dim_sizes = (/num_time,num_lat,num_lon,num_eof/)
    dim_unlims = new(dimsizes(dim_names), logical)
    dim_unlims = False
    filedimdef(fout, dim_names, dim_sizes, dim_unlims)

    filevardef(fout, "time", typeof(fin->time), (/"time"/))
    filevarattdef(fout, "time", fin->time)
    filevardef(fout, "lat", typeof(fin->lat), (/"lat"/))
    filevarattdef(fout, "lat", fin->lat)
    filevardef(fout, "lon", typeof(fin->lon), (/"lon"/))
    filevarattdef(fout, "lon", fin->lon)

    filevardef(fout, "eof", typeof(eof), (/"evn","lat","lon"/))
    filevarattdef(fout, "eof", eof)
    filevardef(fout, "eof_ts", typeof(eof_ts), (/"evn","time"/))
    filevarattdef(fout, "eof_ts", eof_ts)

    setfileoption(fout, "DefineMode", False)

    fout->time = (/fin->time/)
    fout->lat = (/lat(lat_idx)/)
    fout->lon = (/fin->lon/)
    fout->eof = (/eof/)
    fout->eof_ts = (/eof_ts/)

    notice("File "+output+" is created.")

end
