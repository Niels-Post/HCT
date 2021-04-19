# The contents of this makefile can be added at the end of any makefile to help extract its final parameters


# Extract all flags set by BMPTK
commonflags := $(COMMON) $(LIBS)
all_c_flags := $(C_LANGUAGE) $(TARGET_C_FLAGS) $(PROJECT_C_FLAGS)
all_cpp_flags := $(CPP_LANGUAGE) $(CPP_RTTI) $(CPP_EXCEPTIONS) $(CPP_THREADSAFE) $(CPP_CXA) $(TARGET_CPP_FLAGS) $(PROJECT_CPP_FLAGS)


# Output the contents of a list variable, separated by semicolons
%.list:
	$(info $(foreach el,$($*),$(el);))

listify = $(info $(foreach el,$(1),$(el);))

# Output the contents of a single variable
%.var:
	$(info $($*))


