function(hct_add name path makefile)
    set(name ${name})
    set(path ${path})
    set(makefile ${makefile})
    add_subdirectory("$ENV{HCT}/Target_Maker" "${CMAKE_CURRENT_BINARY_DIR}/HCT/${name}" EXCLUDE_FROM_ALL)
endfunction()


function(hct_autoload directory)
    file(GLOB_RECURSE makefiles
            "${directory}/*Makefile")
    foreach (makefile ${makefiles})
        get_filename_component(makefile_name "${makefile}" NAME)
        get_filename_component(makefile_directorypath "${makefile}" DIRECTORY)
        get_filename_component(makefile_directoryname "${makefile_directorypath}" NAME)

        file(READ ${makefile} makefile_contents)
        string(FIND "${makefile_contents}" "include $(HWLIB)" is_hwlib_makefile)

        if (${is_hwlib_makefile} EQUAL -1)
            continue()
        endif ()

        message("\nMakefile found in: ${makefile_directorypath}")
        add_hwlib_bmptk_target("${makefile_directoryname}" "${makefile_directorypath}" "${makefile_name}")
    endforeach ()

endfunction()