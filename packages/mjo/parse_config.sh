function parse_config
{
    notice "Parse configuration for $(add_color mjo 'magenta bold') diagnostics."
    config_file=$1
    check_file_existence "$config_file"
    model_data_root=$(get_config_entry $config_file "model_data_root")
    check_directory_existence "$model_data_root"
    notice "model data root is \"$model_data_root\"."
    model_data_pattern=$(get_config_entry $config_file "model_data_pattern")
    check_file_existence "$model_data_pattern"
    notice "model data pattern is \"$model_data_pattern\"."
    model_data_list=$(get_config_entry $config_file "model_data_list")
    notice "model_data_list is \"$model_data_list\"."
    internal_data_map=$(get_config_entry $config_file "internal_data_map")
    notice "internal_data_map is \"$internal_data_map\"."
    output_directory=$(get_config_entry $config_file "output_directory")
    if [[ -d "$output_directory" ]]; then
        warning "Output directory \"$output_directory\" exists. Override it (y/n)?"
        ans=$(get_answer)
        if [[ "$ans" == "y" ]]; then
            rm -r "$output_directory/*"
            notice "Override \"$output_directory\"."
        elif [[ "$ans" == "n" ]]; then
            report_error "Check that directory and go back"
        else
            report_error "Unknown operation!"
        fi
    else
        notice "Create output directory \"$output_directory\"."
        mkdir "$output_directory"
    fi
}
