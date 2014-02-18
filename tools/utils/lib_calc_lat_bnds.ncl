function calc_lat_bnds(lat[*]:numeric)
local j
begin

    if (lat@units .ne. "degrees_north") then
        report_error("Latitude units ("+lat@units+") is not degrees_north!")
    end if

    lat_bnds = new((/dimsizes(lat),2/), typeof(lat))
    lat_bnds@units = "degrees_north"

    do j = 0, dimsizes(lat)-1
        if (j .eq. 0) then
            lat_bnds(j,0) = (-90.0+lat(j))*0.5
            lat_bnds(j,1) = (lat(j)+lat(j+1))*0.5
        else if (j .eq. dimsizes(lat)-1) then
            lat_bnds(j,0) = (lat(j-1)+lat(j))*0.5
            lat_bnds(j,1) = (lat(j)+90.0)*0.5
        else
            lat_bnds(j,0) = (lat(j-1)+lat(j))*0.5
            lat_bnds(j,1) = (lat(j)+lat(j+1))*0.5
        end if
        end if
    end do

    return lat_bnds

end
