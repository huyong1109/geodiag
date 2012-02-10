; ------------------------------------------------------------------------------
; Description:
;
;   This function will return the variable names, excluding dimension variables,
;   in the given file.
;
; Input:
;
;   - f: file handle
;
; Output:
;
;   - a list of variable name strings
;
; Authors:
;
;   Li Dong
; ------------------------------------------------------------------------------

function get_file_var_names(f)
local dim_names, all_var_names, var_names, i, j
begin

    ; prescribed variable names that should be skiped
    skip_var_patterns = (/"bnds"/)

    dim_names = getvardims(f)
    all_var_names = getfilevarnames(f)

    num_var = 0
    do i = 0, dimsizes(all_var_names)-1
        is_var_skipped = False
        if (.not. any(all_var_names(i) .eq. dim_names)) then
            do j = 0, dimsizes(skip_var_patterns)-1
                if (isStrSubset(all_var_names(i), skip_var_patterns(j))) then
                    is_var_skipped = True
                    break
                end if
            end do
            if (.not. is_var_skipped) then
                num_var = num_var+1
            end if
        end if
    end do
    var_names = new(num_var, string)

    k = 0
    do i = 0, dimsizes(all_var_names)-1
        is_var_skipped = False
        if (.not. any(all_var_names(i) .eq. dim_names)) then
            do j = 0, dimsizes(skip_var_patterns)-1
                if (isStrSubset(all_var_names(i), skip_var_patterns(j))) then
                    is_var_skipped = True
                    break
                end if
            end do
            if (.not. is_var_skipped) then
                var_names(k) = all_var_names(i)
                k = k+1
            end if
        end if
    end do

    return var_names

end

