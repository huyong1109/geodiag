load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

; ------------------------------------------------------------------------------
; Description:
;
;   This script is used to concatenate variable from one or many netcdf files
;   and keep meta data into a single file.
;
;   For the time being, it is called in command line as:
;
;       ncl cat_var.ncl 'datasets="..."' 'var="..."' 'output="..."'
;                       ['var_alias="..."'] [freq=...]
;
;   The 'freq' argument is used when the 'time' coordinate variable in datasets
;   is bad. 'var_alias' is used to change the variable name in output file.
;
; History:
;
;       2014-01-22
;
;           Li Dong     First creation.
; ------------------------------------------------------------------------------

begin

    check_cmd_arg("datasets")
    check_cmd_arg("var")
    var_input = var

    ; user can rename the variable
    if (isdefined("var_alias")) then
        var_output=var_alias
    else
        var_output=var_input
    end if

    if (isdefined("output")) then
        output_file_path = output
    else
        output_file_path = "./"+var_output+".nc"
    end if

    file_paths = systemfunc("ls "+datasets)

    fin = addfile(file_paths(0), "r")
    var_dim_names = getfilevardims(fin, var_input)
    if (.not. any(var_dim_names .eq. "time")) then
        report_error("There no time dimension in data file "+file_paths(0)+"!")
    end if
    var_dim_sizes = getfilevardimsizes(fin, var_input)
    var_type = getfilevartypes(fin, var_input)

    ; check time coordinate variable in input data file
    ; COMPLAIN: Some bad people always messed up data standard!!!
    if (isMonotonic(fin->time) .eq. 0) then
        encounter_bad_time = True
        if (.not. isdefined("freq")) then
            report_error("The time variable in "+file_paths(0)+" is bad, "+ \
                         "but no freq argument is given to reconstruct a "+ \
                         "good time variable, check out the time dimension "+ \
                         "in data and come back!")
        end if
        report_warning("The time variable in "+file_paths(0)+" is bad, "+ \
                       "reconstruct one for you!")
    else
        encounter_bad_time = False
    end if

    ; get the time level number
    num_time = 0
    do i = 0, dimsizes(file_paths)-1
        tmp = addfile(file_paths(i), "r")
        num_time = num_time+getfilevardimsizes(fin, "time")
        delete(tmp)
    end do
    do i = 0, dimsizes(var_dim_sizes)-1
        if (var_dim_names(i) .eq. "time") then
            var_dim_sizes(i) = num_time
            break
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
    filevardef(fout, var_output, var_type, var_dim_names)
    filevarattdef(fout, var_output, fin->$var_input$)

    setfileoption(fout, "DefineMode", False)

    ; set space coordinate variables
    do i = 0, dimsizes(var_dim_sizes)-1
        if (var_dim_names(i) .ne. "time") then
            fout->$var_dim_names(i)$ = (/fin->$var_dim_names(i)$/)
        end if
    end do

    ; set time coordinate variable
    time = new(num_time, getfilevartypes(fin, "time"))
    if (encounter_bad_time) then
        time(0) = 0
        do i = 1, num_time-1
            time(i) = time(i-1)+freq
        end do
    else
        j = 0
        do i = 0, dimsizes(file_paths)-1
            tmp = addfile(file_paths(i), "r")
            num_sub_time = dimsizes(tmp->time)
            time(j:j+num_sub_time-1) = (/tmp->time/)
            j = j+num_sub_time
        end do
    end if
    fout->time = (/time/)

    delete(fin)
    data = new(var_dim_sizes, var_type)
    copy_VarCoords(fout->$var_output$, data)
    j = 0
    if (dimsizes(var_dim_names) .eq. 3) then
        do i = 0, dimsizes(file_paths)-1
            fin = addfile(file_paths(i), "r")
            num_sub_time = dimsizes(fin->time)
            data(j:j+num_sub_time-1,:,:) = (/fin->$var_input$/)
            j = j+num_sub_time
        end do
    else if (dimsizes(var_dim_names) .eq. 4) then
        do i = 0, dimsizes(file_paths)-1
            fin = addfile(file_paths(i), "r")
            num_sub_time = dimsizes(fin->time)
            data(j:j+num_sub_time-1,:,:,:) = (/fin->$var_input$/)
            j = j+num_sub_time
        end do
    else
        report_error("Dimension of variable "+var_input+" is more than 4!")
    end if
    end if
    fout->$var_output$ = (/data/)

    notice("File "+output_file_path+" is created.")

end
