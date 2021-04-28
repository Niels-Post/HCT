# Some C/C++ standards for HWLIB projects
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Have the makefile log every command it does to make debugging easier
set(CMAKE_VERBOSE_MAKEFILE ON)


set(CMD_EXE cmd.exe)

if (NOT EXISTS ${CMD_EXE})
    if (EXISTS C:/Windows/System32/cmd.exe)
        set(CMD_EXE C:/Windows/System32/cmd.exe)
    else ()
        set(CMD_EXE C:/Windows/SysWOW64/cmd.exe)
    endif ()
endif ()

# Runs a target for a specific makefile and reads the output
# Path: Directory the makefile is in
# Makefile: Name of the makefile
# Target: Target to run
# Name of the variable to put the output in
function(get_make_output path makefile target output)
    execute_process(
            COMMAND cmd /c "type ${makefile} $ENV{HCT}\\Makefile.inc > ${makefile}.HCT 2> test & bmptk-make -f ${makefile}.HCT ${target} "
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


# Find the main CPP file for a project.
# If none is found, assume Main
# Sets the project_main variable
function(get_project_main path makefile)
    get_make_output("${path}" "${makefile}" PROJECT.var pr_main)
    if (pr_main MATCHES "^$")
        set(project_main "main" PARENT_SCOPE)
    else ()
        set(project_main "${pr_main}" PARENT_SCOPE)

    endif ()
endfunction()


function(get_sources path makefile search project_main)
    # Parenthesise all paths, just to be sure
    string(REPLACE ";" "\" \"" search_paths "\"${search}\"")
    get_make_output("${path}" "${makefile}" SOURCES.list found_sources)
    set(all_sources "")
    foreach (f ${found_sources})
        # If the source is an absolute path no change is needed
        if ("${f}" MATCHES ^\/ OR "${f}" MATCHES ^.:)
            list(APPEND all_sources "${f}")
            # the Project main does not need to be added twice
        elseif ("${f}" MATCHES "(^${project_main}.cpp$)")
            # For all other files, find the path relative to the output dir
        else ()
            set(a a-NOTFOUND)
            find_file(a "${f}" PATHS ${search_paths})
            if ("${a}" MATCHES a-NOTFOUND)
                message(SEND_ERROR "File: ${f} was not found in ${search_paths}")
            else ()
                file(RELATIVE_PATH relative ${CMAKE_CURRENT_BINARY_DIR} ${a})
                list(APPEND all_sources "${relative}")
            endif ()
        endif ()

    endforeach ()
    set(sources "${all_sources}" PARENT_SCOPE)
endfunction()


get_project_main("${path}" "${makefile}")

# CMake and custom linkerscripts are tricky
# Instead, we use a fake file that needs to be generated before building the application
# To generate a fake file, we just need to build and run the project using make
# (This way, we can use the build button in CLion to run)
add_custom_command(OUTPUT FAKE_FILE_TO_TRICK_CMAKE_INTO_RUNNING_COMMAND_PRE_BUILD.txt
        COMMAND  ${CMD_EXE} /c "bmptk-make -f ${makefile} run || exit 0"
        WORKING_DIRECTORY "${path}"
        VERBATIM USES_TERMINAL)

# Add the target for the application
add_library(${name} OBJECT ${path}/${project_main}.cpp FAKE_FILE_TO_TRICK_CMAKE_INTO_RUNNING_COMMAND_PRE_BUILD.txt)


# Retrieve Common Flags
get_make_output(${path} ${makefile} commonflags.list common_flags_output)
set(common_flags "")
set(includes "")

# In BMPTK, include directories are also in the flags list
# We check if a flag is an include directory
# If so, we don't add it as flag, but as include directory
foreach (f ${common_flags_output})
    if (NOT "${f}" MATCHES -I)
        list(APPEND common_flags "${f}")
    else ()
        string(REPLACE "-I" "" fnoi "${f}")
        get_filename_component(abs "${fnoi}" REALPATH BASE_DIR "${path}")
        list(APPEND includes "${abs}")
    endif ()
endforeach ()
string(REPLACE ";" " " common_flags "${common_flags}")

# Retrieve all language specific flags
get_make_output(${path} ${makefile} all_c_flags.list c_flags)
string(REPLACE ";" " " c_flags "${c_flags}")
get_make_output(${path} ${makefile} all_cpp_flags.list cpp_flags)
string(REPLACE ";" " " cpp_flags "${cpp_flags}")
get_make_output(${path} ${makefile} all_as_flags.list as_flags)
string(REPLACE ";" " " as_flags "${as_flags}")
set(CMAKE_C_FLAGS "${c_flags} ${common_flags}")
set(CMAKE_CXX_FLAGS "${common_flags} ${cpp_flags}")
set(CMAKE_ASM_FLAGS "${common_flags} ${as_flags}")

# Set correct compiler
get_make_output(${path} ${makefile} PREFIX.var prefix)
GET_FILENAME_COMPONENT(prefix_path "${prefix}" REALPATH BASE_DIR "${path}")
if (NOT ${prefix_path} MATCHES "-$")
    set(prefix_path "${prefix_path}/")
endif ()
SET(CMAKE_CXX_COMPILER ${prefix_path}g++)
SET(CMAKE_C_COMPILER ${prefix_path}gcc)
SET(CMAKE_ASM_COMPILER ${prefix_path}gcc)


# Add include directories and source files to the target.
# This is just for autocomplete to work properly
list(APPEND search "${includes}")
list(APPEND search "${path}")
string(APPEND CMAKE_INCLUDE_PATH "${search}")
target_include_directories(${name} PRIVATE "${search}")
get_sources("${path}" "${makefile}" "${search}" "${project_main}")
target_sources("${name}" PUBLIC "${sources}")


message(STATUS "Target loaded: ${name}")
