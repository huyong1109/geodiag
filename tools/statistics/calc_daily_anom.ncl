load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")

    fin = addfile(dataset, "r")

    ; ensure the dataset contains the variable
    if (.not. isfilevar(fin, var)) then
        report_error(var+" is not in "+dataset+"!")
    end if

    ; ensure the variable's dimension is TLL
    var_dim_names = getfilevardims(fin, var)
    if (dimsizes(var_dim_names) .ne. 3) then
        report_error("Sorry, this script currently only handle variables"+ \
                     " with 3 dimensions (time, lat, lon)")
    end if
    necessary_dims = (/"time","lat","lon"/)
    do i = 0, dimsizes(necessary_dims)-1
        if (.not. isfilevarcoord(fin, var, necessary_dims(i))) then
            report_error(var+" in "+dataset+" lacks "+ \
                         necessary_dims(i)+" dimension!")
        end if
    end do

    ; call NCL function to calculate daily anomaly of the variable
    data = fin->$var$
    time = fin->time
    yyyymmdd = cd_calendar(time, -2)
    yyyyddd = yyyymmdd_to_yyyyddd(yyyymmdd)
    var_daily_clim = clmDayTLL(data, yyyyddd)
    var_daily_anom = calcDayAnomTLL(data, yyyyddd, var_daily_clim)

    ; output the daily anomaly
    if (isdefined("output")) then
        output_file_path = output
    else
        output_file_path = var+"_daily_anom.nc"
    end if

    system("rm -f "+output_file_path)
    fout = addfile(output_file_path, "c")

    setfileoption(fout, "DefineMode", True)

    ; define dimensions
    var_dim_sizes = getfilevardimsizes(fin, var)
    dim_unlims = new(dimsizes(var_dim_names), logical)
    dim_unlims = False
    filedimdef(fout, var_dim_names, var_dim_sizes, dim_unlims)

    ; define variables
    do i = 0, dimsizes(var_dim_sizes)-1
        dim_var_type = getfilevartypes(fin, var_dim_names(i))
        filevardef(fout, var_dim_names(i), dim_var_type, var_dim_names(i))
        filevarattdef(fout, var_dim_names(i), fin->$var_dim_names(i)$)
    end do
    filevardef(fout, var, getfilevartypes(fin, var), var_dim_names)
    filevarattdef(fout, var, fin->$var$)

    setfileoption(fout, "DefineMode", False)

    ; set coordinate variables
    do i = 0, dimsizes(var_dim_sizes)-1
        fout->$var_dim_names(i)$ = (/fin->$var_dim_names(i)$/)
    end do

    ; set variable
    fout->$var$ = (/var_daily_anom/)

    notice("File "+output_file_path+" is created.")

end

