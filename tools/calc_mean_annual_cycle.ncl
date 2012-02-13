load "$GEODIAG_UTILS/geodiag_plot_utils.ncl"

begin

    ; --------------------------------------------------------------------------
    ; get arguments
    if (.not. isdefined("file_name_pattern")) then
        notice("Input the data file name pattern:")
        file_name_pattern = get_answer()
    end if

    if (.not. isdefined("var_name")) then
        notice("Input the name of a variable to be averaged:")
        var_name = get_answer()
    end if

    ; --------------------------------------------------------------------------
    file_names = systemfunc("ls "+file_name_pattern)

    f1 = addfile(file_names(0), "r")

    ; --------------------------------------------------------------------------
    ; check time dimension
    num_time = dimsizes(file_names)
    if (num_time .eq. 1) then
        ; all data in one file
        if (.not. isfilevar(f1, "time")) then
            report_error("There is no time variable in "+file_names(0)+"!")
        end if
        ; TODO: here we assume the time variable is conformed to the standard
        date = cd_calendar(f1->time, 0)
        start_year = date(0,0)
        end_year = date(dimsizes(f1->time)-1,0)
        if (date(0,1) .ne. 1) then
            ; remove the first year
            start_year = start_year+1
        end if
        if (date(dimsizes(f1->time)-1,1) .ne. 12) then
            ; remove the last year
            end_year = end_year-1
        end if
        notice("Start year is "+start_year)
        notice("End year is "+end_year)
        num_year = end_year-start_year+1
        if (num_year .le. 0) then
            report_error("There are not sufficient years to do the average!")
        end if
        time_idx = ind(date(:,0) .ge. start_year .and. date(:,0) .le. end_year)
        is_all_in_one_file = True
    else
        start_file_idx = 0
        end_file_idx = num_time-1
        if (num_time%12 .ne. 0) then
            report_warning("The number of data file is not a multiplier of 12!")
            notice("Input the start file name:")
            start_file = get_answer()
            notice("Input the end file name:")
            end_file = get_answer()
            start_file_idx = ind(file_names .eq. start_file)
            end_file_idx = ind(file_names .eq. end_file)
            num_time = num_time-(start_file_idx+1)-(num_time-end_file_idx)
        end if
        num_year = num_time/12
        is_all_in_one_file = False
    end if
    month = ispan(1, 12, 1)
    month!0 = "month"
    month@long_name = "month"

    ; --------------------------------------------------------------------------
    ; check coordinate names and its corresponding variables
    dim_names = getvardims(f1)
    has_bnds = False
    if (any(dim_names .eq. "bnds")) then
        has_bnds = True
    end if
    dim_sizes = getfiledimsizes(f1)
    var_dim_names = getfilevardims(f1, var_name)
    if (all(var_dim_names .ne. "time")) then
        report_error("There is no time dimension in variable "+var_name)
    end if
    var_dim_sizes = new(dimsizes(var_dim_names), integer)
    do i = 0, dimsizes(dim_names)-1
        if (dim_names(i) .eq. "time") then
            ; replace the time to month
            dim_names(i) = "month"
            dim_sizes(i) = 12
            break
        end if
    end do
    do i = 0, dimsizes(var_dim_names)-1
        if (var_dim_names(i) .ne. "time") then
            var_dim_sizes(i) = dimsizes(f1->$var_dim_names(i)$)
        else
            var_dim_names(i) = "month"
            var_dim_sizes(i) = 12
        end if
    end do

    ; --------------------------------------------------------------------------
    ; setup variable
    var = new(var_dim_sizes, float)
    do i = 0, dimsizes(var_dim_names)-1
        var!i = var_dim_names(i)
        if (var_dim_names(i) .eq. "month") then
            var&$var_dim_names(i)$ = month
        else
            var&$var_dim_names(i)$ = f1->$var_dim_names(i)$
        end if
    end do
    var@long_name = f1->$var_name$@long_name
    var@units = f1->$var_name$@units
    var@missing_value = f1->$var_name$@missing_value
    var@_FillValue = f1->$var_name$@_FillValue

    ; --------------------------------------------------------------------------
    ; average
    var = 0.0
    do i = 0, 11
        system("echo averaging month "+(i+1))
        if (is_all_in_one_file) then
            mon_idx = time_idx(i:dimsizes(time_idx)-1:12)
            if (dimsizes(var_dim_names)-1 .eq. 2) then
                var(i,:,:) = dim_avg_n(f1->$var_name$(mon_idx,:,:), 0)
            end if
            if (dimsizes(var_dim_names)-1 .eq. 3) then
                var(i,:,:,:) = dim_avg_n(f1->$var_name$(mon_idx,:,:,:), 0)
            end if
            if (dimsizes(var_dim_names)-1 .eq. 4) then
                var(i,:,:,:,:) = dim_avg_n(f1->$var_name$(mon_idx,:,:,:,:), 0)
            end if
        else
            mon_file_names = file_names(start_file_idx+i:end_file_idx:12)
            do j = 0, dimsizes(mon_file_names)-1
                f = addfile(mon_file_names(j), "r")
                if (dimsizes(var_dim_names)-1 .eq. 2) then
                    var(i,:,:) = var(i,:,:)+dim_avg_n(f->$var_name$, 0)
                end if
                if (dimsizes(var_dim_names)-1 .eq. 3) then
                    var(i,:,:,:) = var(i,:,:,:)+dim_avg_n(f->$var_name$, 0)
                end if
                if (dimsizes(var_dim_names)-1 .eq. 4) then
                    var(i,:,:,:,:) = var(i,:,:,:,:)+dim_avg_n(f->$var_name$, 0)
                end if
            end do
        end if
    end do
    if (.not. is_all_in_one_file) then
        var = where(ismissing(var), var@missing_value, var/num_year)
    end if

    file_name = var_name+".nc"
    system("test -f "+file_name+" && rm "+file_name)
    f2 = addfile(file_name, "c")

    notice("File "+file_name+" is created.")

    setfileoption(f2, "DefineMode", True)

    dim_unlim = new(dimsizes(dim_names), logical)
    dim_unlim = False
    filedimdef(f2, dim_names, dim_sizes, dim_unlim)

    do i = 0, dimsizes(dim_names)-1
        if (dim_names(i) .eq. "month") then
            filevardef(f2, dim_names(i), "integer", dim_names(i))
            filevarattdef(f2, dim_names(i), month)
        else
            if (isfilevar(f1, dim_names(i))) then
                filevardef(f2, dim_names(i), "float", dim_names(i))
                filevarattdef(f2, dim_names(i), f1->$dim_names(i)$)
                if (has_bnds) then
                    ; add the bounds of the coordinate variables
                    ; TODO: here we assume the name of the variable bounds has
                    ;       the following pattern
                    dim_var_bnds = dim_names(i)+"_bnds"
                    if (isfilevar(f1, dim_var_bnds)) then
                        filevardef(f2, dim_var_bnds, "float", (/dim_names(i),"bnds"/))
                        filevarattdef(f2, dim_var_bnds, f1->$dim_var_bnds$)
                    end if
                end if
            end if
        end if
    end do
    filevardef(f2, var_name, "float", getvardims(var))

    setfileoption(f2, "DefineMode", False)

    do i = 0, dimsizes(dim_names)-1
        if (dim_names(i) .eq. "month") then
            f2->$dim_names(i)$ = (/month/)
        else
            if (isfilevar(f1, dim_names(i))) then
                if (typeof(f1->$dim_names(i)$) .eq. "double") then
                    f2->$dim_names(i)$ = (/doubletofloat(f1->$dim_names(i)$)/)
                else
                    f2->$dim_names(i)$ = (/f1->$dim_names(i)$/)
                end if
                if (has_bnds) then
                    ; add the bounds of the coordinate variables
                    dim_var_bnds = dim_names(i)+"_bnds"
                    if (isfilevar(f1, dim_var_bnds)) then
                        if (typeof(f1->$dim_var_bnds$) .eq. "double") then
                            f2->$dim_var_bnds$ = (/doubletofloat(f1->$dim_var_bnds$)/)
                        else
                            f2->$dim_var_bnds$ = (/f1->$dim_var_bnds$/)
                        end if
                    end if
                end if
            end if
        end if
    end do
    f2->$var_name$ = (/var/)
    f2->$var_name$@long_name = var@long_name
    f2->$var_name$@units = var@units
    f2->$var_name$@missing_value = var@missing_value

end
