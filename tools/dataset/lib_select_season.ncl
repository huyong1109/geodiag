load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function select_season(dataset, season)
local fin, time
begin

    fin = addfile(dataset, "r")

    ; ensure the dataset contains time coordinate variable
    if (.not. isfilevar(fin, "time")) then
        report_error("There is no time coordinate variable in "+dataset+"!")
    end if

    time = fin->time

    tmp = cd_calendar(time, 0)

    if (season .eq. "all") then
        idx = ispan(0, dimsizes(time)-1, 1)
    end if
    if (season .eq. "DJF" .or. season .eq. "boreal_winter") then
        idx = ind(tmp(:,1) .eq. 12 .or. tmp(:,1) .eq. 1 .or. tmp(:,1) .eq. 2)
    end if
    if (season .eq. "JJA" .or. season .eq. "boreal_summer") then
        idx = ind(tmp(:,1) .eq.  6 .or. tmp(:,1) .eq. 7 .or. tmp(:,1) .eq. 8)
    end if

    return(idx)

end
