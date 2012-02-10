; ------------------------------------------------------------------------------
; Description:
;
;   This procedure is used to select the lat-lon ranges for a given region.
;
; Input:
;
;   - region: string of a specified region name
;   - option: 1 for -180~180 longitude, others for 0~360
;
; Output:
;
;   - min_lon, max_lon, min_lat, max_lat: the lat-lon ranges
;
; Authors:
;
;   Li Dong
; ------------------------------------------------------------------------------

procedure select_region(region:string, min_lon:numeric, max_lon:numeric, \
    min_lat:numeric, max_lat:numeric, option:integer)
begin

    found = False

    if (region .eq. "global") then
        min_lon = 0.0
        max_lon = 360.0
        min_lat = -90.0
        max_lat = 90.0
        found = True
    end if

    if (region .eq. "china") then
        min_lon = 75.0
        max_lon = 135.0
        min_lat = 10.0
        max_lat = 55.0
        found = True
    end if

    if (region .eq. "northern china") then
        min_lon = 75.0
        max_lon = 135.0
        min_lat = 35.0
        max_lat = 55.0
        found = True
    end if

    if (region .eq. "tibetan plateau") then
        min_lon = 75.0
        max_lon = 103.0
        min_lat = 25.0
        max_lat = 40.0
        found = True
    end if

    if (region .eq. "western pacific warm pool") then
        min_lon = 70.0
        max_lon = 150.0
        min_lat = -5.0
        max_lat = 20.0
        found = True
    end if

    if (region .eq. "northern pacific") then
        min_lon = 160.0
        max_lon = 235.0
        min_lat = 40.0
        max_lat = 60.0
        found = True
    end if

    if (region .eq. "peru coast") then
        min_lon = 230.0
        max_lon = 290.0
        min_lat = -40.0
        max_lat = 0.0
        found = True
    end if

    if (region .eq. "nino34") then
        min_lon = 190.0
        max_lon = 240.0
        min_lat = -5.0
        max_lat = 5.0
        found = True
    end if

    if (found .and. option .eq. 1) then
        ; the longitude is from -180 to 180
        if (min_lon .gt. 180.0) then
            min_lon = min_lon-360.0
        end if
        if (max_lon .gt. 180.0) then
            max_lon = max_lon-360.0
        end if
        if (region .eq. "global") then
            min_lon = -180.0
            max_lon = 180.0
        end if
    end if

    if (.not. found) then
        system("echo Unknown region "+region)
        exit
    end if

end

; ------------------------------------------------------------------------------
; Description:
;
;   This function returns the longitude indices for a given region.
;
; Input:
;
;   - region: string of a specified region name
;   - lon: the longitude array
;
; Output:
;
;   - a list of longitude indices
;
; Authors:
;
;   Li Dong
; ------------------------------------------------------------------------------

function select_region_lon(region:string, lon[*]:numeric)
local option, min_lon, max_lon, min_lat, max_lat, min_i, max_i, i, lon_bnds
begin

    if (any(lon .lt. 0.0)) then
        option = 1
    else
        option = 0
    end if

    ; --------------------------------------------------------------------------
    num_lon = dimsizes(lon)
    lon_bnds = new((/num_lon,2/), typeof(lon))
    do i = 1, num_lon-1
        lon_bnds(i,0) = (lon(i)+lon(i-1))*0.5
        lon_bnds(i-1,1) = lon_bnds(i,0)
    end do
    lon_bnds(0,0) = lon(0)-(lon(1)-lon(0))*0.5
    lon_bnds(num_lon-1,1) = lon(num_lon-1)+(lon(num_lon-1)-lon(num_lon-2))*0.5

    ; --------------------------------------------------------------------------
    min_lon = new(1, typeof(lon))
    max_lon = new(1, typeof(lon))
    min_lat = new(1, typeof(lon))
    max_lat = new(1, typeof(lon))
    select_region(region, min_lon, max_lon, min_lat, max_lat, option)

    min_i = -1
    max_i = -1

    ; --------------------------------------------------------------------------
    min_lon = max((/min_lon,lon_bnds(0,0)/))
    min_lon = min((/min_lon,lon_bnds(num_lon-1,1)/))
    max_lon = min((/max_lon,lon_bnds(num_lon-1,1)/))
    max_lon = max((/max_lon,lon_bnds(0,0)/))

    ; --------------------------------------------------------------------------
    do i = 0, num_lon-1
        if (min_lon .ge. lon_bnds(i,0) .and. min_lon .lt. lon_bnds(i,1)) then
            min_i = i
            break
        end if
    end do
    min_i = max((/0,min_i/))

    do i = 0, num_lon-1
        if (max_lon .ge. lon_bnds(i,0) .and. max_lon .lt. lon_bnds(i,1)) then
            max_i = i
            break
        end if
    end do
    ; TODO: Make sure this is ok.
    ; exceeds the boundary, reset max_i to the boundary index
    if (max_i .eq. -1) then
        max_i = num_lon-1
    end if
    max_i = min((/num_lon-1,max_i/))

    ; --------------------------------------------------------------------------
    if (min_i .lt. max_i) then
        lon_idx = ispan(min_i, max_i, 1)
    end if
    if (min_i .gt. max_i) then
        span = max_i+1+num_lon-min_i
        lon_idx = new((/span/), integer)
        lon_idx(0:max_i) = ispan(0, max_i, 1)
        lon_idx(max_i+1:span-1) = ispan(min_i, num_lon-1, 1)
    end if

    return lon_idx

end

; ------------------------------------------------------------------------------
; Description:
;
;   This function returns the latitude indices for a given region.
;
; Input:
;
;   - region: string of a specified region name
;   - lat: the latitude array
;
; Output:
;
;   - a list of latitude indices
;
; Authors:
;
;   Li Dong
; ------------------------------------------------------------------------------

function select_region_lat(region:string, lat[*]:numeric)
local min_lon, max_lon, min_lat, max_lat, min_j, max_j, j, lat_bnds
begin

    option = isMonotonic(lat)

    ; --------------------------------------------------------------------------
    num_lat = dimsizes(lat)
    lat_bnds = new((/num_lat,2/), typeof(lat))
    do j = 1, num_lat-1
        lat_bnds(j,0) = (lat(j)+lat(j-1))*0.5
        lat_bnds(j-1,1) = lat_bnds(j,0)
    end do
    lat_bnds(0,0) = lat(0)-(lat(1)-lat(0))*0.5
    lat_bnds(num_lat-1,1) = lat(num_lat-1)+(lat(num_lat-1)-lat(num_lat-2))*0.5

    ; --------------------------------------------------------------------------
    min_lon = new(1, typeof(lat))
    max_lon = new(1, typeof(lat))
    min_lat = new(1, typeof(lat))
    max_lat = new(1, typeof(lat))
    select_region(region, min_lon, max_lon, min_lat, max_lat, 0)

    min_j = -1
    max_j = -1

    ; --------------------------------------------------------------------------
    if (option .eq. 1) then
        min_lat = max((/min_lat,lat_bnds(0,0)/))
        min_lat = min((/min_lat,lat_bnds(num_lat-1,1)/))
        max_lat = min((/max_lat,lat_bnds(num_lat-1,1)/))
        max_lat = max((/max_lat,lat_bnds(0,0)/))
    else
        min_lat = max((/min_lat,lat_bnds(num_lat-1,1)/))
        min_lat = min((/min_lat,lat_bnds(0,0)/))
        max_lat = min((/max_lat,lat_bnds(0,0)/))
        max_lat = max((/max_lat,lat_bnds(num_lat-1,1)/))
    end if

    ; --------------------------------------------------------------------------
    if (option .eq. 1) then
        do j = 0, num_lat-1
            if (min_lat .ge. lat_bnds(j,0) .and. min_lat .lt. lat_bnds(j,1)) then
                min_j = j
                break
            end if
        end do
    else
        do j = 0, num_lat-1
            if (max_lat .le. lat_bnds(j,0) .and. max_lat .gt. lat_bnds(j,1)) then
                min_j = j
                break
            end if
        end do
    end if
    min_j = max((/0,min_j/))

    if (option .eq. 1) then
        do j = 0, num_lat-1
            if (max_lat .gt. lat_bnds(j,0) .and. max_lat .le. lat_bnds(j,1)) then
                max_j = j
                break
            end if
        end do
    else
        do j = 0, num_lat-1
            if (min_lat .lt. lat_bnds(j,0) .and. min_lat .ge. lat_bnds(j,1)) then
                max_j = j
                break
            end if
        end do
    end if
    if (max_j .eq. -1) then
        max_j = num_lat-1
    end if
    max_j = min((/num_lat-1,max_j/))

    ; --------------------------------------------------------------------------
    span = max_j-min_j+1
    lat_idx = ispan(min_j, max_j, 1)

    return lat_idx

end
