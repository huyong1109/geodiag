load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset")
    check_cmd_arg("season")
    check_cmd_arg("var")

    if (isdefined("output")) then
        output_file_path = output
    else
        output_file_path = "./"+var+"_"+season+".nc"
    end if

    fin = addfile(dataset, "r")

    time_idx = select_season(dataset, season)

    var_dim_names = getfilevardims(fin, var)
    var_dim_sizes = getfilevardimsizes(fin, var)
    var_type = getfilevartypes(fin, var)

    ; change time dimension size
    do i = 0, dimsizes(var_dim_sizes)-1
        if (var_dim_names(i) .eq. "time") then
            var_dim_sizes(i) = dimsizes(time_idx)
        end if
    end do

    system("rm -f "+output_file_path)
    fout = addfile(output_file_path, "c")

    setfileoption(fout, "DefineMode", True)

    ; define dimensions
    dim_unlims = new(dimsizes(var_dim_names), logical)
    dim_unlims = False
    filedimdef(fout, var_dim_names, var_dim_sizes, dim_unlims)

    ; define variables
    do i = 0, dimsizes(var_dim_sizes)-1
        dim_var_type = getfilevartypes(fin, var_dim_names(i))
        filevardef(fout, var_dim_names(i), dim_var_type, var_dim_names(i))
        filevarattdef(fout, var_dim_names(i), fin->$var_dim_names(i)$)
    end do
    filevardef(fout, var, var_type, var_dim_names)
    filevarattdef(fout, var, fin->$var$)

    setfileoption(fout, "DefineMode", False)

    ; set coordinate variables
    do i = 0, dimsizes(var_dim_sizes)-1
        if (var_dim_names(i) .eq. "time") then
            fout->time = (/fin->time(time_idx)/)
        else
            fout->$var_dim_names(i)$ = (/fin->$var_dim_names(i)$/)
        end if
    end do

    if (dimsizes(var_dim_names) .eq. 3) then
        fout->$var$ = (/fin->$var$(time_idx,:,:)/)
    else if (dimsizes(var_dim_names) .eq. 4) then
        fout->$var$ = (/fin->$var$(time_idx,:,:,:)/)
    end if
    end if

    notice("File "+output_file_path+" is created.")

end
