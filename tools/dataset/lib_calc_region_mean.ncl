load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function calc_region_mean(fin:file, var:string, min_lon:numeric, max_lon:numeric, min_lat:numeric, max_lat:numeric)
local lon_idx, lat_idx, lat_bnds, lat_wgts, var_dim_names, data
begin

    lon_idx = select_lon(min_lon, max_lon, fin->lon)
    lat_idx = select_lat(min_lat, max_lat, fin->lat)

    var_dim_names = getfilevardims(fin, var)

    ; create latitudinal weights
    lat_bnds = calc_lat_bnds(fin->lat)
    lat_wgts = calc_lat_wgts(lat_bnds(lat_idx,:))

    var_dim_names = getfilevardims(fin, var)
    if (dimsizes(var_dim_names) .eq. 2) then
        if (var_dim_names(0) .eq. "lat"  .and. \
            var_dim_names(1) .eq. "lon") then
            data = wgt_areaave_Wrap(fin->$var$(lat_idx,lon_idx), lat_wgts, 1.0, 0)
        else
            report_error("The dimensions of "+var+" is not (lat, lon)!")
        end if
    else if (dimsizes(var_dim_names) .eq. 3) then
        if (var_dim_names(0) .eq. "time" .and. \
            var_dim_names(1) .eq. "lat"  .and. \
            var_dim_names(2) .eq. "lon") then
            data = wgt_areaave_Wrap(fin->$var$(:,lat_idx,lon_idx), lat_wgts, 1.0, 0)
        else
            report_error("The dimensions of "+var+" is not (time, lat, lon)!")
        end if
    else
        report_error("More than 3 dimensions case in calc_lat_wgts is under construction!")
    end if
    end if

    return data

end
