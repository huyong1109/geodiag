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
;       ncl cat_var.ncl 'datasets="..."'
;                       'var="..."'
;                       ['var_alias="..."']
;                       'output="..."'
;                       [start_date=...]
;                       [end_date=...]
;                       [freq=...]
;
;   The date format should be YYYYMMDD.
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

    if (.not. isdefined("start_date")) then
        start_date = -1
    end if

    if (.not. isdefined("end_date")) then
        end_date = -1
    end if

    if (.not. isdefined("freq")) then
        freq = 1
    end if

    file_paths = systemfunc("ls "+datasets)

    fin = addfile(file_paths(0), "r")
    if (.not. isfilevar(fin, var_input)) then
        report_error("There is no variable "+var_input+" in "+file_paths(0)+"!")
    end if
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

    ; get the all time level number
    num_all_time = 0
    do i = 0, dimsizes(file_paths)-1
        tmp = addfile(file_paths(i), "r")
        num_all_time = num_all_time+getfilevardimsizes(tmp, "time")
        delete(tmp)
    end do

    ; get the all time variable and find out the needed time level in which files
    all_time = new(num_all_time, double)
    all_time@units = "days since 0001-01-01 00:00:00"
    all_time@calendar = "standard"
    k1 = 0
    k2 = 0
    ; the whole files are used in default
    start_file_idx = 0
    end_file_idx = dimsizes(file_paths)-1
    start_file_time_idx = -1
    end_file_timeIdx = -1
    found_start_file = start_date .eq. -1
    found_end_file = end_date .eq. -1
    do i = 0, dimsizes(file_paths)-1
        tmp = addfile(file_paths(i), "r")
        num_file_time = getfilevardimsizes(tmp, "time")
        k2 = k1+num_file_time-1
        all_time(k1:k2) = (/cd_convert(tmp->time, all_time@units)/)
        ; only do the following judgement when we haven't found the start and
        ; end file yet, and the start and end date must not be equal to -1
        if ((start_date .ne. -1 .and. .not. found_start_file) .or. \
            (end_date   .ne. -1 .and. .not. found_end_file)) then
            yyyymmdd = cd_calendar(tmp->time, -2)
            if (start_date .ne. -1 .and. .not. found_start_file) then
                do j = 0, num_file_time-1
                    if (yyyymmdd(j) .ge. start_date) then
                        start_time_idx = k1+j
                        start_file_idx = i
                        start_file_time_idx = j
                        found_start_file = True
                        break
                    end if
                end do
            end if
            ; only judge end file when the start file has been found
            if (found_start_file .and. .not. found_end_file .and. \
                end_date .ne. -1 .and. .not. found_end_file) then
                do j = 0, num_file_time-1
                    if (yyyymmdd(j) .gt. end_date) then
                        ;system("echo "+yyyymmdd(j-1)+" "+end_date)
                        end_time_idx = k1+j-1
                        end_file_idx = i
                        end_file_time_idx = j-1
                        found_end_file = True
                        break
                    else if (yyyymmdd(j) .eq. end_date) then
                        ;system("echo "+yyyymmdd(j)+" "+end_date)
                        end_time_idx = k1+j
                        end_file_idx = i
                        end_file_time_idx = j
                        found_end_file = True
                        break
                    end if
                    end if
                end do
            end if
        end if
        k1 = k2+1
    end do
    num_time = end_time_idx-start_time_idx+1 ; this is the time number we need
    ;print(all_time(start_time_idx:end_time_idx))
    ;print(file_paths(start_file_idx:end_file_idx))
    ;exit

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
        if (var_dim_names(i) .ne. "time") then
            filevarattdef(fout, var_dim_names(i), fin->$var_dim_names(i)$)
        else
            filevarattdef(fout, "time", all_time)
        end if
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
    time = new(num_time, typeof(all_time))
    if (encounter_bad_time) then
        time(0) = 0
        do i = 1, num_time-1
            time(i) = time(i-1)+freq
        end do
    else
        ; TODO: Apply 'freq' here.
        if (freq .ne. 1) then
            report_error("Under construction!")
        end if
        time = all_time(start_time_idx:end_time_idx)
    end if
    fout->time = (/time/)

    delete(fin)
    data = new(var_dim_sizes, var_type)
    copy_VarCoords(fout->$var_output$, data) ; TODO: Do we need this?
    j = 0
    if (dimsizes(var_dim_names) .eq. 3) then
        fin = addfile(file_paths(start_file_idx), "r")
        if (start_file_idx .eq. end_file_idx) then
            n = end_file_time_idx-start_file_time_idx+1
            data(0:n-1,:,:) = (/fin->$var_input$(start_file_time_idx:end_file_time_idx,:,:)/)
        else
            n = getfilevardimsizes(fin, "time")-start_file_time_idx
            data(0:n-1,:,:) = (/fin->$var_input$(start_file_time_idx:,:,:)/)
        end if
        j = j+n
        do i = start_file_idx+1, end_file_idx-1
            fin = addfile(file_paths(i), "r")
            n = getfilevardimsizes(fin, "time")
            data(j:j+n-1,:,:) = (/fin->$var_input$/)
            j = j+n
        end do
        if (start_file_idx .ne. end_file_idx) then
            fin = addfile(file_paths(end_file_idx), "r")
            data(j:,:,:) = (/fin->$var_input$(:end_file_time_idx,:,:)/)
        end if
    else if (dimsizes(var_dim_names) .eq. 4) then
        fin = addfile(file_paths(start_file_idx), "r")
        if (start_file_idx .eq. end_file_idx) then
            n = end_file_time_idx-start_file_time_idx+1
            data(0:n-1,:,:,:) = (/fin->$var_input$(start_file_time_idx:end_file_time_idx,:,:,:)/)
        else
            n = getfilevardimsizes(fin, "time")-start_file_time_idx
            data(0:n-1,:,:,:) = (/fin->$var_input$(start_file_time_idx:,:,:,:)/)
        end if
        j = j+n
        do i = start_file_idx+1, end_file_idx-1
            fin = addfile(file_paths(i), "r")
            n = getfilevardimsizes(fin, "time")
            data(j:j+n-1,:,:,:) = (/fin->$var_input$/)
            j = j+n
        end do
        if (start_file_idx .ne. end_file_idx) then
            fin = addfile(file_paths(end_file_idx), "r")
            data(j:,:,:,:) = (/fin->$var_input$(:end_file_time_idx,:,:,:)/)
        end if
    else
        report_error("Dimension of variable "+var_input+" is more than 4!")
    end if
    end if
    fout->$var_output$ = (/data/)

    notice("File "+output_file_path+" is created.")

end
