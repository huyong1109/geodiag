function parse_config
{
    notice "Parse configuration for $(add_color mjo 'magenta bold') diagnostics."
    config_file=$1
    check_file_existence "$config_file"
    cmor_data_root=$(get_config_entry $config_file "cmor_data_root")
    check_directory_existence "$cmor_data_root"
    notice "cmor_data_root is \"$cmor_data_root\"."
    cmor_exp_id=$(get_config_entry $config_file "cmor_exp_id")
    notice "cmor_exp_id is \"$cmor_exp_id\"."
    cmor_data_list=$(get_config_entry $config_file "cmor_data_list")
    for cmor_data in $cmor_data_list; do
        if [[ ! -d "$cmor_data_root/day/atmos/$cmor_data" ]]; then
            report_error "Data $cmor_data does not exist!"
        fi
        if [[ ! -d "$cmor_data_root/day/atmos/$cmor_data/$cmor_exp_id" ]]; then
            report_error "Experiment $cmor_exp_id of data $cmor_data does not exist!"
        fi
    done
    notice "cmor_data_list is \"$cmor_data_list\"."
    internal_data_map=$(get_config_entry $config_file "internal_data_map")
    notice "internal_data_map is \"$internal_data_map\"."
    start_date=$(get_config_entry $config_file "start_date")
    notice "start_date is \"$start_date\"."
    end_date=$(get_config_entry $config_file "end_date")
    notice "end_date is \"$end_date\"."
    diag_stages=$(get_config_entry $config_file "diag_stages")
    notice "diag_stages is \"$diag_stages\"."
    output_directory=$(get_config_entry $config_file "output_directory")
    if [[ -d "$output_directory" ]]; then
        report_warning "Output directory \"$output_directory\" exists. Override it (y/n)?"
        ans=$(get_answer)
        if [[ "$ans" == "y" ]]; then
            rm -r "$output_directory"
            mkdir "$output_directory"
            notice "Override \"$output_directory\"."
        elif [[ "$ans" == "n" ]]; then
            report_warning "Use that directory!"
        else
            report_error "Unknown operation!"
        fi
    else
        notice "Create output directory \"$output_directory\"."
        mkdir "$output_directory"
    fi
}
