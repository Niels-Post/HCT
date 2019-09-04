cmake_minimum_required(VERSION 2.8)


set(HWLIB_TOOL_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(WSL_HOMEDIR "${HWLIB_TOOL_DIR}/..")
set(HWLIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/submodules/hwlib/library)
set(BMPTK_DIR ${CMAKE_CURRENT_SOURCE_DIR}/submodules/bmptk)
set(SFML_DIR ${WSL_HOMEDIR}/SFML)
set(CATCH_DIR ${CMAKE_CURRENT_SOURCE_DIR}/submodules/catch2/single_include/catch2)
if (POLICY CMP0076)
    cmake_policy(SET CMP0076 NEW)
endif ()



set(CATCH_MAKE_DIRECTIVE "SEARCH += $(HOME)/Catch2/single_include\nSEARCH += $(HOME)/Catch2/single_include/catch2")

function(clean_hwlib_build path)
    execute_process(
            COMMAND "${MAKE_BAT}" -f "${path}/Makefile" clean
            WORKING_DIRECTORY "${path}")
    message("-- Directory Cleaned")
endfunction()

function(extract_hwlib_arguments path)
    list(LENGTH ARGN ln)
    if (ln GREATER 0)
        message("-- Using HWLIB")
        list(GET ARGN 0 HWLIB_TARGET)
        set(HWLIB_TARGET ${HWLIB_TARGET} PARENT_SCOPE)
        if (HWLIB_TARGET)
            clean_hwlib_build(${path})
        endif ()
    else ()
        message("-- Not Using HWLIB")
    endif ()
    if (ln GREATER 1)
        list(GET ARGN 1 BMPTK_TARGET)
        set(BMPTK_TARGET ${BMPTK_TARGET} PARENT_SCOPE)
    endif ()
    if (ln GREATER 2)
        list(GET ARGN 2 MAKE_SERIAL_PORT)
        if (add_make_variables)
            set(MAKE_SERIAL_PORT "SERIAL_PORT := ${MAKE_SERIAL_PORT}" PARENT_SCOPE)
        else ()
            set(MAKE_SERIAL_PORT "${MAKE_SERIAL_PORT}" PARENT_SCOPE)
        endif ()
    endif ()
    if (ln GREATER 3)
        list(GET ARGN 3 MAKE_CONSOLE_BAUDRATE)
        if (add_make_variables)
            set(MAKE_CONSOLE_BAUDRATE "CONSOLE_BAUDRATE := ${MAKE_CONSOLE_BAUDRATE}" PARENT_SCOPE)
        else ()
            set(MAKE_CONSOLE_BAUDRATE "${MAKE_CONSOLE_BAUDRATE}" PARENT_SCOPE)
        endif ()
    endif ()
    if (ln GREATER 4)
        list(GET ARGN 4 NO_MAKEFILE)
        set(NO_MAKEFILE ${NO_MAKEFILE} PARENT_SCOPE)
    endif ()
endfunction()

function(create_target name path use_hwlib)
    if (use_hwlib)


        add_custom_command(OUTPUT "${name}_command_output.cpp"
                COMMAND "${MAKE_BAT}" -f "${path}/Makefile" clean
                COMMAND "${MAKE_BAT}" -f "${path}/Makefile"
                #                COMMAND echo "test" > "${name}_command_output.cpp"
                WORKING_DIRECTORY "${path}"
                USES_TERMINAL
                COMMENT "Running makefile in WSL"
                )

        add_executable(
                ${name}
                "${name}_command_output.cpp")
    else ()
        add_executable(${TARGET_NAME} "${path}/main.cpp")
    endif ()
endfunction()

function(get_mainsources path)
    file(GLOB_RECURSE absolute_sources ${path}/*.cpp ${path}/*.asm)
    list(FILTER absolute_sources EXCLUDE REGEX .*main.cpp)

    foreach (abssource ${absolute_sources})
        file(RELATIVE_PATH rel ${path} ${abssource})
        list(APPEND relative_sources ${rel})
    endforeach ()

    set(MAINSOURCES_ABSOLUTE ${absolute_sources} PARENT_SCOPE)

    set(MAINSOURCES_RELATIVE ${relative_sources} PARENT_SCOPE)
endfunction()

function(retrieve_bmptk_definitions path)
    execute_process(
            COMMAND "${MAKE_BAT}" -f "${path}/Makefile" debugtarget
            WORKING_DIRECTORY "${path}"
            OUTPUT_VARIABLE OutVar)

    string(REGEX MATCHALL "-D[^ ]*" Defines "${OutVar}")
    string(REGEX REPLACE "(^|;)-D" "\\1" Defines "${Defines}")

    set(BMPTK_DEFINITIONS "${Defines}" PARENT_SCOPE)
endfunction()


function(add_hwlib_target TARGET_NAME path)
    message("--------------------------------------------------------")
    message("Target: ${TARGET_NAME}")
    set(add_make_variables TRUE)
    extract_hwlib_arguments(${path} ${ARGN})
    create_target(${TARGET_NAME} "${path}" "${HWLIB_TARGET}")

    get_mainsources(${path})

    if (HWLIB_TARGET)
        list(APPEND
                INCLUDES
                ${HWLIB_DIR}
                ${BMPTK_DIR}/targets/avr/include
                ${BMPTK_DIR}/targets/cortex/stm32
                ${BMPTK_DIR}/targets/cortex/atmel
                ${BMPTK_DIR}/targets/cortex/lpc
                ${BMPTK_DIR}/targets/avr/include

                ${SFML_DIR}
                ${CATCH_DIR}
                )
        list(APPEND
                SOURCES
                "${HWLIB_DIR}/hwlib.cpp"
                )
        list(APPEND
                DEFINITIONS
                ${HWLIB_TARGET}
                _HWLIB_ONCE
                CMAKE_ONLY)
        if (${BMPTK_TARGET} STREQUAL native)
            set(MAKE_CPP_FLAGS "PROJECT_CPP_FLAGS += -fexceptions")
            set(CATCH2_INCLUDE "${CATCH_MAKE_DIRECTIVE}")
        endif ()


    endif ()

    string(REPLACE ";" " " MAKE_SOURCES "${MAINSOURCES_RELATIVE}")
    message("-- Sources: ${MAKE_SOURCES}")
    if(NOT ${NO_MAKEFILE})
    configure_file(${HWLIB_TOOL_DIR}/Makefile.convert ${path}/Makefile)
    endif()
    target_sources(${TARGET_NAME} PRIVATE ${MAINSOURCES_ABSOLUTE} ${SOURCES})

    if (HWLIB_TARGET)
        retrieve_bmptk_definitions(${path})
        message("-- BMPTK Definitions:  ${BMPTK_DEFINITIONS}")
    endif ()
    list(APPEND DEFINITIONS ${BMPTK_DEFINITIONS})

    target_compile_definitions(${TARGET_NAME} PRIVATE ${DEFINITIONS})
    target_include_directories(${TARGET_NAME} PRIVATE ${INCLUDES})
endfunction()


function(hwlib_load_auto starting_path)
    file(GLOB_RECURSE mains ${starting_path}/*/main.cpp)
    foreach (file ${mains})
        get_filename_component(path "${file}" DIRECTORY)
        string(REGEX MATCH "[^/]*$" name "${path}")
        file(STRINGS "${path}/main.cpp" opt LIMIT_COUNT 1)
        string(REGEX MATCHALL "[^ ;]*=[^ ;]*" variables "${opt}")
        set(add_make_variables "")
        extract_hwlib_arguments(${path} ${ARGN})
        hwlib_autoload_context("${name}" "${path}" ${variables})
    endforeach ()
endfunction()

function(hwlib_autoload_context name path)
    foreach (opt ${ARGN})
        string(REGEX MATCH "(.*)=(.*)" option_parts "${opt}")
        set(${CMAKE_MATCH_1} ${CMAKE_MATCH_2})
        set(FOUND true)
    endforeach ()

    add_hwlib_target("${name}" "${path}" "${HWLIB_TARGET}" "${BMPTK_TARGET}" "${MAKE_SERIAL_PORT}" "${MAKE_CONSOLE_BAUDRATE}")

endfunction()