load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "$GEODIAG_ROOT/geodiag.ncl"

begin

    check_cmd_arg("dataset1")
    check_cmd_arg("dataset2")

    if (isdefined("var1")) then
        check_cmd_arg("var2")
    else
        check_cmd_arg("var")
        var1 = var
        var2 = var
    end if

    check_cmd_arg("output")

    fin1 = addfile(dataset1, "r")
    fin2 = addfile(dataset2, "r")

    if (.not. isfilevar(fin1, var1)) then
        report_error("File "+dataset1+" does not contain variable "+var1+"!")
    end if
    if (.not. isfilevar(fin2, var2)) then
        report_error("File "+dataset2+" does not contain variable "+var2+"!")
    end if

    var1_dim_names = getfilevardims(fin1, var1)
    var2_dim_names = getfilevardims(fin2, var2)
    var1_dim_sizes = getfilevardimsizes(fin1, var1)
    var2_dim_sizes = getfilevardimsizes(fin2, var2)
    var1_type = getfilevartypes(fin1, var1)
    var2_type = getfilevartypes(fin2, var2)

    if (dimsizes(var1_dim_names) .ne. dimsizes(var2_dim_names)) then
        report_error(var1+" and "+var2+" do not have the same number of dimensions!")
    end if
    do i = 0, dimsizes(var1_dim_names)-1
        if (var1_dim_names(i) .ne. var2_dim_names(i)) then
            report_error(var1+" and "+var2+" do not have the same dimensionality!")
        end if
        if (var1_dim_sizes(i) .ne. var2_dim_sizes(i)) then
            report_error(var1+" and "+var2+" do not have the same dimensionality!")
        end if
    end do
    if (var1_type .ne. var2_type) then
        report_error(var1+" and "+var2+" do not have the same type!")
    end if

    system("rm -f "+output)
    fout = addfile(output, "c")

    setfileoption(fout, "DefineMode", True)

    dim_unlims = new(dimsizes(var1_dim_names), logical)
    dim_unlims = False
    filedimdef(fout, var1_dim_names, var1_dim_sizes, dim_unlims)

    do i = 0, dimsizes(var1_dim_names)-1
        dim_var_type = getfilevartypes(fin1, var1_dim_names(i))
        filevardef(fout, var1_dim_names(i), dim_var_type, var1_dim_names(i))
        filevarattdef(fout, var1_dim_names(i), fin1->$var1_dim_names(i)$)
    end do
    filevardef(fout, var1, var1_type, var1_dim_names)
    filevarattdef(fout, var1, fin1->$var1$)

    setfileoption(fout, "DefineMode", False)

    do i = 0, dimsizes(var1_dim_sizes)-1
        fout->$var1_dim_names(i)$ = (/fin1->$var1_dim_names(i)$/)
    end do

    v1 = (/fin1->$var1$/)
    v1@_FillValue = 0.0
    v2 = (/fin2->$var2$/)
    v2@_FillValue = 0.0
    fout->$var1$ = (/v1/v2/)

    notice("File "+output+" is created.")

end
