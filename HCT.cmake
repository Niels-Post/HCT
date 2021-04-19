if(POLICY CMP0076)
    cmake_policy(SET CMP0076 NEW)
endif()


# Function to add a target manually
function(hct_add name path makefile)
    string(REPLACE = "_eq" name "${name}")
    set(name ${name})
    set(path ${path})
    set(makefile ${makefile})
    add_subdirectory("$ENV{HCT}/Target_Maker" "${CMAKE_CURRENT_BINARY_DIR}/HCT/${name}" EXCLUDE_FROM_ALL)
endfunction()

# Recursively find HWLIB makefiles and add them to the project
function(hct_autoload directory)
    # Find all files called Makefile
    file(GLOB_RECURSE makefiles "${directory}/*Makefile")
    foreach (makefile ${makefiles})

        # Split the makefile path into its components
        get_filename_component(makefile_name "${makefile}" NAME)
        get_filename_component(makefile_directorypath "${makefile}" DIRECTORY)
        get_filename_component(makefile_directoryname "${makefile_directorypath}" NAME)

        file(READ ${makefile} makefile_contents)
        # Check if Makefile is a project Makefile (not an included makefile)
        string(FIND "${makefile_contents}" "$(HWLIB)/makefile.inc" is_hwlib_makefile)
        string(FIND "${makefile_contents}" "$(RELATIVE)/Makefile." is_relative_makefile)
        string(FIND "${makefile_contents}" "#HCTMarker" is_hct_marked)
        if (${is_hwlib_makefile} EQUAL -1 AND ${is_hct_marked} EQUAL -1 AND ${is_relative_makefile} EQUAL -1)
            continue()
        endif ()

        # Load the target
        hct_add("${makefile_directoryname}" "${makefile_directorypath}" "${makefile_name}")
    endforeach ()

endfunction()