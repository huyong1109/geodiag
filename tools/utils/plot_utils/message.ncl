; ------------------------------------------------------------------------------
; Description:
;
;   These procedures are used to unify the message printing form.
;
; Authors:
;
;   Li Dong
; ------------------------------------------------------------------------------

procedure notice(message)
begin

    system("echo [Notice]: "+message)

end

procedure report_warning(message)
begin

    system("echo [Warning]: "+message)

end

procedure report_error(message)
begin

    system("echo [Error]: "+message)
    exit

end

function get_answer()
begin

    ans = systemfunc("read -e -p '> ' ans && echo $ans")
    return ans

end
