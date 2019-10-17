set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_VERBOSE_MAKEFILE ON)

function(add_hct_make_targets)
    execute_process(
            COMMAND bash -c "cat '${makefile}' '$ENV{HCT}/Makefile.inc' > '${makefile}.HCT'"
            WORKING_DIRECTORY "${path}"
            INPUT_FILE "${makefile}"
    )
endfunction()

function(make_get variable)
    execute_process(
            COMMAND make -f "${makefile}.HCT" -s "${variable}.list"
            WORKING_DIRECTORY "${path}"
            OUTPUT_VARIABLE value
    )
    string(REPLACE "; " ";" value "${value}")
    string(REPLACE "\n" "" value "${value}")
    SET(${variable} "${value}" PARENT_SCOPE)
endfunction()

function(make_get_one variable)
    make_get("${variable}")
    if (${variable} MATCHES ^$)
        set(${variable} "" PARENT_SCOPE)

    else ()
        list(GET ${variable} 0 value)
        set(${variable} "${value}" PARENT_SCOPE)
    endif ()
endfunction()

function(make_get_multiple output variables)
    set(all_values "")
    foreach (var ${variables})
        make_get("${var}" "${path}" "${makefile}")
        string(APPEND all_values "${${var}}")
    endforeach ()
    string(SUBSTRING "${all_values}" 1 -1 all_values)
    set(${output} "${all_values}" PARENT_SCOPE)
endfunction()

function(de_list var value)
    string(REPLACE ";" "\" \"" val "\"${value}\"")
    set(${var} "${val}" PARENT_SCOPE)
endfunction()


add_hct_make_targets()

make_get_one(PROJECT)

add_library(${name} OBJECT "${path}/${PROJECT}")

make_get_multiple(COMMON_FLAGS_LIST "ARCH_FLAGS;ALL_ERRORS;ALL_IGNORE;ALL_OPTIMIZATION;ALL_SECTIONS;ALL_LIBRARIES;DEFINES")
make_get_multiple(C_FLAGS_LIST "C_LANGUAGE;TARGET_C_FLAGS;PROJECT_C_FLAGS")
make_get_multiple(AS_FLAGS_LIST "AS_LANGUAGE;TARGET_AS_FLAGS;PROJECT_AS_FLAGS")
make_get_multiple(CPP_FLAGS_LIST "CPP_LANGUAGE;CPP_LPTHREAD;CPP_RTTI;CPP_EXCEPTIONS;CPP_THREADSAFE;CPP_CXA;TARGET_CPP_FLAGS;PROJECT_CPP_FLAGS")

de_list(COMMON_FLAGS "${COMMON_FLAGS_LIST}")
de_list(C_FLAGS "${C_FLAGS_LIST}")
de_list(CPP_FLAGS "${CPP_FLAGS_LIST}")
de_list(AS_FLAGS "${AS_FLAGS_LIST}")

set(CMAKE_C_FLAGS "${C_FLAGS} ${COMMONFLAGS}")
set(CMAKE_ASM_FLAGS "${AS_FLAGS} ${COMMONFLAGS}")
set(CMAKE_CXX_FLAGS "${CPP_FLAGS} ${COMMONFLAGS}")

make_get_one(PREFIX)
SET(CMAKE_CXX_COMPILER ${PREFIX}g++)
SET(CMAKE_C_COMPILER ${PREFIX}gcc)
SET(CMAKE_ASM_COMPILER ${PREFIX}gcc)

make_get(INCLUDES)
de_list(INCLUDES "${INCLUDES}")
string(REPLACE "-I" "" INCLUDES "${INCLUDES}")
string(APPEND CMAKE_INCLUDE_PATH "${INCLUDES}")

make_get(HEADERS)

make_get(ALL_LIBRARIES)
de_list(COMMON_FLAGS "${COMMONFLAGS}")
message("${CPP_FLAGS}")
#message("${COMMONFLAGS}")
