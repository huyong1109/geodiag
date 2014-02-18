function calc_lat_wgts(lat_bnds[*][*]:numeric)
begin

    tmp = dimsizes(lat_bnds)
    if (tmp(1) .ne. 2) then
        report_error("The second dimension size of latitude bounds argument is not 2!")
    end if
    lat_wgts = new(tmp(0), typeof(lat_bnds))

    do j = 0, tmp(0)-1
        lat_wgts(j) = sin(deg_to_rad(lat_bnds(j,1)))-sin(deg_to_rad(lat_bnds(j,0)))
    end do

    return lat_wgts

end
