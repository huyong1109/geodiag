load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")

    fin = addfile(dataset, "r")

    if (.not. isfilevar(fin, "time")) then
        report_error("Dataset "+dataset+" does not contain time coordinate variable!")
    end if
    time = fin->time
    if (.not. isatt(time, "units")) then
        report_error("Time coordinate variable does not contain units!")
    end if

    if (isdefined("start_ymd")) then
        year = start_ymd/10000
        month = (start_ymd-year*10000)/100
        day = start_ymd-year*10000-month*100
        start_time = cd_inv_calendar(year, month, day, 0, 0, 0, time@units, 0)
        do i = 0, dimsizes(time)-1
            if (time(i) .ge. start_time) then
                start_time_idx = i
                break
            end if
        end do
    else
        start_time_idx = 0
    end if
    if (isdefined("end_ymd")) then
        year = end_ymd/10000
        month = (end_ymd-year*10000)/100
        day = end_ymd-year*10000-month*100
        end_time = cd_inv_calendar(year, month, day, 0, 0, 0, time@units, 0)
        do i = dimsizes(time)-1, 0, 1
            if (time(i) .le. end_time) then
                end_time_idx = i
                break
            end if
        end do
    else
        end_time_idx = dimsizes(time)-1
    end if

    num_dim = dimsizes(dimsizes(fin->$var$))
    if (num_dim .eq. 3) then
        var_input = fin->$var$(start_time_idx:end_time_idx,:,:)
    else if (num_dim .eq. 4) then
        var_input = fin->$var$(start_time_idx:end_time_idx,:,:,:)
    else
        report_error("Variable "+var+" in "+dataset+" should be 2D or 3D with time dimension!")
    end if
    end if

    var_output = dim_variance_n_Wrap(var_input, 0)

    ; output filtered variable
    if (isdefined("output")) then
        output_file_path = output
    else
        output_file_path = var+"_variance.nc"
    end if

    system("rm -f "+output_file_path)
    fout = addfile(output_file_path, "c")

    setfileoption(fout, "DefineMode", True)

    ; define dimensions
    var_dim_names = getvardims(var_output)
    var_dim_sizes = new(dimsizes(var_dim_names), integer)
    do i = 0, dimsizes(var_dim_sizes)-1
        var_dim_sizes(i) = dimsizes(fin->$var_dim_names(i)$)
    end do
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
    fout->$var$ = (/var_output/)
    fout->$var$@long_name = fout->$var$@long_name+" variance"

    notice("File "+output_file_path+" is created.")

end

