cmake_minimum_required (VERSION 2.8)

project (geodiag_cmor CXX)
# ------------------------------------------------------------------------------
# external libraries
include (ExternalProject)
# cmor
include_directories ("${CMOR_ROOT}/include")
# geomtk
ExternalProject_Add (geomtk
    URL ${PROJECT_SOURCE_DIR}/../geomtk
    PREFIX geotmk
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/../shared
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_SOURCE_DIR}/../shared
)
ExternalProject_Get_Property(geomtk INSTALL_DIR)
set (geomtk_install_dir ${INSTALL_DIR})
include_directories (${geomtk_install_dir}/include)
# set suffix of shared library
if (APPLE)
    set (shared_suffix "dylib")
elseif (UNIX)
    set (shared_suffix "so")
endif ()
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
add_dependencies (geodiag_cmor geomtk)
target_link_libraries (geodiag_cmor
    ${geomtk_install_dir}/lib/libgeomtk.${shared_suffix}
)
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
