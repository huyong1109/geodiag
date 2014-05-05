cmake_minimum_required (VERSION 2.8)

project (geodiag_cmor CXX)

include_directories ("${CMOR_ROOT}/include")

# ------------------------------------------------------------------------------
# source directory structure
set (source_directories
    "${PROJECT_SOURCE_DIR}/src"
    "${PROJECT_SOURCE_DIR}/src/ModelData"
)
# ------------------------------------------------------------------------------
# collect sources and headers
foreach (dir ${source_directories})
    include_directories ("${dir}")
    # header files
    file (GLOB tmp1 "${dir}/*.h")
    list (APPEND headers ${tmp1})
    # source files
    aux_source_directory ("${dir}" tmp2)
    list (APPEND sources ${tmp2})
endforeach ()
# ------------------------------------------------------------------------------
# library targets
add_library (geodiag_cmor SHARED ${headers} ${sources})
target_link_libraries (geodiag_cmor)
# ------------------------------------------------------------------------------
# executable targets
foreach (dir ${source_directories})
    if (EXISTS "${dir}/driver")
        include_directories ("${dir}/driver")
        aux_source_directory ("${dir}/driver" driver_paths)
        foreach (driver_path ${driver_paths})
            get_filename_component (driver ${driver_path} NAME_WE)
            add_executable (${driver} ${driver_path})
            target_link_libraries (${driver} geodiag_cmor)
            add_dependencies (${driver} geodiag_cmor)
        endforeach ()
    endif ()
endforeach ()
