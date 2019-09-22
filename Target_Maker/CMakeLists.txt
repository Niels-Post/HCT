
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)


set(CMAKE_VERBOSE_MAKEFILE ON)

function(get_make_output path makefile target output)
    execute_process(
            COMMAND bash -c "cat '${makefile}' '${HCT}/Makefile.inc' > '${makefile}.HCT' &&  make -f '${makefile}.HCT' '${target}' "
            WORKING_DIRECTORY "${path}"
            OUTPUT_VARIABLE OutVar
            INPUT_FILE "${makefile}")
    string(REPLACE "; " ";" OutVar "${OutVar}")


    if (OutVar MATCHES ^\n)
        SET(${output} "" PARENT_SCOPE)
    else ()
        string(REGEX MATCH "([^\n]*)" _ "${OutVar}")
        SET(${output} "${CMAKE_MATCH_1}" PARENT_SCOPE)
    endif ()
endfunction()

function(get_defines path makefile)
    get_make_output(${path} ${makefile} get_defines output)
    string(REGEX MATCHALL "-D[^ ]*" Defines "${output}")
    string(REGEX REPLACE "(^|;)-D" "\\1" Defines "${Defines}")
    set(defines "${Defines}" PARENT_SCOPE)
endfunction()

function(get_project_main path makefile)
    get_make_output("${path}" "${makefile}" get_project pr_main)
    if (pr_main MATCHES "^$")
        set(project_main "main" PARENT_SCOPE)
    else ()
        set(project_main "${pr_main}" PARENT_SCOPE)

    endif ()
endfunction()


function(get_sources path makefile search project_main)
    string(REPLACE ";" "\" \"" search_paths "${search}")
    set(search_paths "\"${search_paths}\"")
    get_make_output("${path}" "${makefile}" get_sources output)
    set(all_sources "")
    foreach (f ${output})
        if ("${f}" MATCHES ^\/)
            list(APPEND all_sources "${f}")
        elseif ("${f}" MATCHES "(^${project_main}.cpp$)")
        else ()
            set(a a-NOTFOUND)
            find_file(a "${f}" PATHS ${search_paths})
            if ("${a}" MATCHES a-NOTFOUND)
                message(SEND_ERROR "File: ${f} was not found in ${search_paths}")
            else ()
                message(STATUS "File ${f} found as ${a}")
                file(RELATIVE_PATH relative ${CMAKE_CURRENT_BINARY_DIR} ${a})
                list(APPEND all_sources "${relative}")
            endif ()
        endif ()

    endforeach ()
    set(sources "${all_sources}" PARENT_SCOPE)
endfunction()


get_project_main("${path}" "${makefile}")

add_library(${name} OBJECT ${path}/${project_main}.cpp)

#set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_CXX_STANDARD 11)
set_property(TARGET ${name} PROPERTY CXX_STANDARD 17)
set_property(TARGET ${name} PROPERTY C_STANDARD 11)

# Retrieve Common Flags
get_make_output(${path} ${makefile} get_common_flags common_flags_output)
set(common_flags "")
set(includes "")

foreach (f ${common_flags_output})
    # Ignore includes, we'll get those later anyway
    if (NOT "${f}" MATCHES -I)
        list(APPEND common_flags "${f}")
    else ()
        string(REPLACE "-I" "" fnoi "${f}")
        get_filename_component(abs "${fnoi}" REALPATH BASE_DIR "${path}")
        list(APPEND includes "${abs}")
    endif ()
endforeach ()
string(REPLACE ";" " " common_flags "${common_flags}")

# Retrieve C Flags
get_make_output(${path} ${makefile} get_c_flags c_flags)
string(REPLACE ";" " " c_flags "${c_flags}")
get_make_output(${path} ${makefile} get_cpp_flags cpp_flags)
string(REPLACE ";" " " cpp_flags "${cpp_flags}")
get_make_output(${path} ${makefile} get_as_flags as_flags)
string(REPLACE ";" " " as_flags "${as_flags}")

set(CMAKE_C_FLAGS "${c_flags} ${common_flags}")
set(CMAKE_CXX_FLAGS "${common_flags} ${cpp_flags}")
set(CMAKE_ASM_FLAGS "${common_flags} ${as_flags}")
# Set correct compiler
get_make_output(${path} ${makefile} get_prefix prefix)
SET(CMAKE_CXX_COMPILER ${prefix}g++)
SET(CMAKE_C_COMPILER ${prefix}gcc)
SET(CMAKE_ASM_COMPILER ${prefix}gcc)


# Retrieve includes
#get_includes("${path}" "${makefile}")
list(APPEND search "${includes}")
list(APPEND search "${path}")
string(APPEND CMAKE_INCLUDE_PATH "${search}")
target_include_directories(${name} PRIVATE "${search}")
#    target_include_directories(${name} PRIVATE ${WSL_HOMEDIR}/SFML)

message("\n Looking for source for ${name}")
get_sources("${path}" "${makefile}" "${search}" "${project_main}")


target_sources("${name}" PUBLIC "${sources}")

add_custom_target("${name}_builder" bash -c "sudo make -f '${makefile}' run || exit 0"
        WORKING_DIRECTORY "${path}"
        VERBATIM)
add_dependencies("${name}" "${name}_builder")
#    set_target_properties(${name} PROPERTIES LINK_DEPENDS "${path}/${ln_script}")

message(STATUS "Target loaded: ${name}")
message("------------------------------")