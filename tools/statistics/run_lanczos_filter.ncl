load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

; --------------------------------------------------------------------------
; Description:
;
;   This script is used to apply Lanczos filter on the given variable.
;
;       ncl run_lanczos_filter.ncl 'dataset="..."' 'pass="..."' time_step=..
;                                  [start_time=...] [end_time=...]
;
; History:
;
;   2014-01-23
;
;       Li Dong     First creation.
; --------------------------------------------------------------------------

begin

    check_cmd_arg("dataset")
    check_cmd_arg("var")
    check_cmd_arg("pass")
    check_cmd_arg("time_step")
    check_cmd_arg("num_wgt")

    if (pass .eq. "low") then
        ihp = 0
    else if (pass .eq. "high") then
        ihp = 1
    else if (pass .eq. "band") then
        ihp = 2
    else
        report_error("Argument pass ("+pass+") must be low, high or band!")
    end if
    end if
    end if

    if (pass .ne. "high" .and. .not. isdefined("end_time")) then
        report_error("Argument end_time is not presented!")
    end if
    if (pass .ne. "low" .and. .not. isdefined("start_time")) then
        report_error("Argument start_time is not presented!")
    end if

    ; set cutoff frequencies
    if (pass .ne. "high") then
        fca = int2flt(time_step)/end_time
    else
        fca = -999.0
    end if
    if (pass .ne. "low") then
        fcb = int2flt(time_step)/start_time
    else
        fcb = -999.0
    end if

    ; TODO: Check num_wgt is odd.

    lanczos_wgts = filwgts_lanczos(num_wgt, ihp, fca, fcb, 1)

    ; plot Lanczos response function
    if (isdefined("plot_resp_func") .and. plot_resp_func) then
        wks = gsn_open_wks("pdf", "lanczos_response_function")

        res = True
        res@gsnMaximize = True
        res@trXMinF = 0.0
        res@trXMaxF = 0.1
        res@trYMinF = -0.01
        res@trYMaxF = 1.01
        res@tmXBTickStartF = res@trXMinF
        res@tmXBTickEndF = res@trXMaxF
        res@tmYLTickStartF = res@trYMinF
        res@tmYLTickEndF = res@trYMaxF
        res@tiXAxisString = "frequency"
        res@tiYAxisString = "response"
        res@tiMainString = "Lanczos filter response function"

        plot = gsn_csm_xy(wks, lanczos_wgts@freq, lanczos_wgts@resp, res)

        notice("Lanczos response function is plotted as lanczos_response_function.pdf.")
    end if

    ; apply Lanczos filter on the dataset
    fin = addfile(dataset, "r")

    filtered_var = wgt_runave_n(fin->$var$, lanczos_wgts, 0, 0)

    ; output filtered variable
    if (isdefined("output")) then
        output_file_path = output
    else
        output_file_path = var+"_filtered.nc"
    end if

    system("rm -f "+output_file_path)
    fout = addfile(output_file_path, "c")

    setfileoption(fout, "DefineMode", True)

    ; define dimensions
    var_dim_names = getfilevardims(fin, var)
    var_dim_sizes = getfilevardimsizes(fin, var)
    do i = 0, dimsizes(var_dim_sizes)-1
        if (var_dim_names(i) .eq. "time") then
            num_half_wgt = (num_wgt-1)/2
            num_origin_time = dimsizes(fin->time)
            time = fin->time(num_half_wgt:num_origin_time-num_half_wgt-1)
            var_dim_sizes(i) = var_dim_sizes(i)-2*num_half_wgt
            notice("The first and last "+num_half_wgt+" data are removed due to boundary effect.")
        end if
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
        if (var_dim_names(i) .eq. "time") then
            fout->time = (/time/)
        else
            fout->$var_dim_names(i)$ = (/fin->$var_dim_names(i)$/)
        end if
    end do

    ; set variable
    if (dimsizes(var_dim_sizes) .eq. 3) then
        fout->$var$ = (/filtered_var(num_half_wgt:num_origin_time-num_half_wgt-1,:,:)/)
    else if (dimsizes(var_dim_sizes) .eq. 4) then
        fout->$var$ = (/filtered_var(num_half_wgt:num_origin_time-num_half_wgt-1,:,:,:)/)
    end if
    end if
    fout->$var$@long_name = fout->$var$@long_name+", filtered by Lanczos filter"

    notice("File "+output_file_path+" is created.")

end

