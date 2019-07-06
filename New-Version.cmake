

set(MAKE_BAT "${WSL_HOMEDIR}/run_make.bat")


function(make_output path makefile target)
    execute_process(
            COMMAND C:/Windows/Sysnative/wsl "make" -f "${makefile}" ${target}
            WORKING_DIRECTORY "${path}"
            OUTPUT_VARIABLE OutVar)

    string(REPLACE "\n" ";" OutVar ${OutVar})
    list(GET OutVar 0 result)
    SET(output "${result}" PARENT_SCOPE)
endfunction()

function(get_defines path makefile)
    make_output(${path} ${makefile} get_defines)
    string(REGEX MATCHALL "-D[^ ]*" Defines "${output}")
    string(REGEX REPLACE "(^|;)-D" "\\1" Defines "${Defines}")
    set(defines "${Defines}" PARENT_SCOPE)
endfunction()

function(get_search path makefile)
    make_output(${path} ${makefile} get_search)
    string(REPLACE "./" "" nosingledots "${output}")
    STRING(REPLACE " " ";" nospaces "${nosingledots}")
    set(search "${nospaces}" PARENT_SCOPE)
endfunction()

function(get_sources path makefile search)
    string(REPLACE ";" " " search_paths "${search}")
    make_output(${path} ${makefile} get_sources)
    string(REPLACE "./" "" nosingledots "${output}")
    STRING(REPLACE " " ";" nospaces "${nosingledots}")
    set(all_sources "")
    foreach (f ${nospaces})
        if ("${f}" MATCHES [\/])
            list(APPEND all_sources "${f}")
        else ()
            find_file(found "${f}" PATHS ${search_paths})
            file(RELATIVE_PATH relative ${path} ${found})
            list(APPEND all_sources "${relative}")
        endif ()
    endforeach ()
    set(sources "${all_sources}" PARENT_SCOPE)
endfunction()


function(add_hwlib_bmptk_target name path makefile)
    add_executable(${name})
    get_defines("${path}" "${makefile}")
    message("Defines: " "${defines}")
    target_compile_definitions(${name} PRIVATE ${defines})
    get_search("${path}" "${makefile}")
    message("Search: " "${search}")
    list(APPEND CMAKE_INCLUDE_PATH ${search})
    target_include_directories(${name} PRIVATE ${search})
    target_include_directories(${name} PRIVATE ${WSL_HOMEDIR}/SFML)
    get_sources("${path}" "${makefile}" "${search}")
    message("Sources: " "${sources}")
    target_sources(${name} PRIVATE ${sources})

endfunction()