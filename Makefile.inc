
listify = $(info $(foreach el,$(1),$(el);))

get_sources:
	$(call listify,$(SOURCES))


get_includes:
	$(call listify,$(INCLUDES))



commonflags := $(COMMON) $(LIBS)
get_common_flags:
	$(call listify,$(commonflags))

get_project:
	$(info $(PROJECT))


get_as_flags:
	$(call listify,$(all_as_flags))

c_only_flags := $(C_LANGUAGE) $(TARGET_C_FLAGS) $(PROJECT_C_FLAGS)

get_c_flags:
	$(call listify,$(c_only_flags))

cpp_only_flags := $(CPP_LANGUAGE) $(CPP_RTTI) $(CPP_EXCEPTIONS) $(CPP_THREADSAFE) $(CPP_CXA) $(TARGET_CPP_FLAGS) $(PROJECT_CPP_FLAGS)

get_cpp_flags:
	$(call listify,$(cpp_only_flags))


get_prefix:
	$(info $(PREFIX))

