# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.5

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /evix/rtrlib-0.3.6

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /evix/rtrlib-0.3.6

# Include any dependencies generated for this target.
include tools/CMakeFiles/rtrclient.dir/depend.make

# Include the progress variables for this target.
include tools/CMakeFiles/rtrclient.dir/progress.make

# Include the compile flags for this target's objects.
include tools/CMakeFiles/rtrclient.dir/flags.make

tools/CMakeFiles/rtrclient.dir/rtrclient.c.o: tools/CMakeFiles/rtrclient.dir/flags.make
tools/CMakeFiles/rtrclient.dir/rtrclient.c.o: tools/rtrclient.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/evix/rtrlib-0.3.6/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object tools/CMakeFiles/rtrclient.dir/rtrclient.c.o"
	cd /evix/rtrlib-0.3.6/tools && /usr/bin/cc  $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/rtrclient.dir/rtrclient.c.o   -c /evix/rtrlib-0.3.6/tools/rtrclient.c

tools/CMakeFiles/rtrclient.dir/rtrclient.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/rtrclient.dir/rtrclient.c.i"
	cd /evix/rtrlib-0.3.6/tools && /usr/bin/cc  $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /evix/rtrlib-0.3.6/tools/rtrclient.c > CMakeFiles/rtrclient.dir/rtrclient.c.i

tools/CMakeFiles/rtrclient.dir/rtrclient.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/rtrclient.dir/rtrclient.c.s"
	cd /evix/rtrlib-0.3.6/tools && /usr/bin/cc  $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /evix/rtrlib-0.3.6/tools/rtrclient.c -o CMakeFiles/rtrclient.dir/rtrclient.c.s

tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.requires:

.PHONY : tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.requires

tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.provides: tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.requires
	$(MAKE) -f tools/CMakeFiles/rtrclient.dir/build.make tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.provides.build
.PHONY : tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.provides

tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.provides.build: tools/CMakeFiles/rtrclient.dir/rtrclient.c.o


# Object files for target rtrclient
rtrclient_OBJECTS = \
"CMakeFiles/rtrclient.dir/rtrclient.c.o"

# External object files for target rtrclient
rtrclient_EXTERNAL_OBJECTS =

tools/rtrclient: tools/CMakeFiles/rtrclient.dir/rtrclient.c.o
tools/rtrclient: tools/CMakeFiles/rtrclient.dir/build.make
tools/rtrclient: librtr.so.0.3.6
tools/rtrclient: /usr/lib/x86_64-linux-gnu/librt.so
tools/rtrclient: /usr/lib/x86_64-linux-gnu/libssh.so
tools/rtrclient: tools/CMakeFiles/rtrclient.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/evix/rtrlib-0.3.6/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable rtrclient"
	cd /evix/rtrlib-0.3.6/tools && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/rtrclient.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
tools/CMakeFiles/rtrclient.dir/build: tools/rtrclient

.PHONY : tools/CMakeFiles/rtrclient.dir/build

tools/CMakeFiles/rtrclient.dir/requires: tools/CMakeFiles/rtrclient.dir/rtrclient.c.o.requires

.PHONY : tools/CMakeFiles/rtrclient.dir/requires

tools/CMakeFiles/rtrclient.dir/clean:
	cd /evix/rtrlib-0.3.6/tools && $(CMAKE_COMMAND) -P CMakeFiles/rtrclient.dir/cmake_clean.cmake
.PHONY : tools/CMakeFiles/rtrclient.dir/clean

tools/CMakeFiles/rtrclient.dir/depend:
	cd /evix/rtrlib-0.3.6 && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /evix/rtrlib-0.3.6 /evix/rtrlib-0.3.6/tools /evix/rtrlib-0.3.6 /evix/rtrlib-0.3.6/tools /evix/rtrlib-0.3.6/tools/CMakeFiles/rtrclient.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tools/CMakeFiles/rtrclient.dir/depend
