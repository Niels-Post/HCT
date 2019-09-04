
#
#get_defines:
#	$(info    $(DEFINES))
#
#get_libs:
#	$(info    $(LIBS))
#
get_sources:
	$(info    $(SOURCES))

get_headers:
	$(info    $(HEADERS))

get_includes:
	$(info $(INCLUDES))

get_search:
	$(info    $(SEARCH))


commonflags := $(COMMON) $(LIBS)
get_common_flags:
	$(info $(commonflags))


get_ln_flags:
	$(info $(LN_FLAGS))

as_only_flags := $(AS_LANGUAGE) $(TARGET_AS_FLAGS)  $(PROJECT_AS_FLAGS)

get_as_flags:
	$(info $(all_as_flags))

c_only_flags := $(C_LANGUAGE) $(TARGET_C_FLAGS) $(PROJECT_C_FLAGS)

get_c_flags:
	$(info $(c_only_flags))

cpp_only_flags := $(CPP_LANGUAGE) $(CPP_RTTI) $(CPP_EXCEPTIONS) $(CPP_THREADSAFE) $(CPP_CXA) $(TARGET_CPP_FLAGS) $(PROJECT_CPP_FLAGS)

get_cpp_flags:
	$(info $(cpp_only_flags))


get_prefix:
	$(info $(PREFIX))