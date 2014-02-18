procedure check_cmd_arg(arg_name)
begin

    if (.not. isdefined(arg_name)) then
        report_error("Argument "+arg_name+" is not presented!")
    end if

end
