load "$GEODIAG_UTILS/geodiag_plot_utils.ncl"

begin

    if (.not. isdefined("dir")) then
        notice("Input the data directory:")
        dir = get_answer()
    end if

    if (.not. isdefined("var_name")) then
        notice("Input the name of a variable to be averaged:")
        var_name = get_answer()
    end if

    file_names = systemfunc("ls "+dir+"/*.nc")

    check_file_exist(file_names)

    num_time = dimsizes(file_names)
    num_year = num_time/12
    month = ispan(0, 11, 1)
    month!0 = "month"
    month@long_name = "month"

    f1 = addfile(file_names(0), "r")
    dim_names = getvardims(f1)
    dim_sizes = getfiledimsizes(f1)
    var_dim_names = getfilevardims(f1, var_name)
    var_dim_sizes = new(dimsizes(var_dim_names), integer)
    do i = 0, dimsizes(dim_names)-1
        if (dim_names(i) .eq. "time") then
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

    var = new(var_dim_sizes, float)
    var = 0.0
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

    do i = 0, 11
        system("echo averaging "+i)
        mon_file_names = file_names(i:num_time-1:12)
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
    end do
    var = where(ismissing(var), var@missing_value, var/num_year)

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
        else
            if (isfilevar(f1, dim_names(i))) then
                filevardef(f2, dim_names(i), "float", dim_names(i))
                filevarattdef(f2, dim_names(i), f1->$dim_names(i)$)
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
                f2->$dim_names(i)$ = (/doubletofloat(f1->$dim_names(i)$)/)
            end if
        end if
    end do
    f2->$var_name$ = (/var/)
    f2->$var_name$@long_name = var@long_name
    f2->$var_name$@units = var@units
    f2->$var_name$@missing_value = var@missing_value

end
