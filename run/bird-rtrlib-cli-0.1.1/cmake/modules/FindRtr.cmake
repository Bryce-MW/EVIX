# - Try to find RTR
# Once done this will define
#
#  RTR_FOUND - system has RTR
#  RTR_INCLUDE_DIRS - the RTR include directory
#  RTR_LIBRARIES - Link these to use RTR
#  RTR_DEFINITIONS - Compiler switches required for using RTR
#
#  Copyright (c) 2016 smlng <s@mlng.net>
#  based on FindArgp.cmake by Andreas Schneider <asn@cynapses.org>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#


if (RTR_LIBRARIES AND RTR_INCLUDE_DIRS)
  # in cache already
  set(RTR_FOUND TRUE)
else (RTR_LIBRARIES AND RTR_INCLUDE_DIRS)

  find_path(RTR_INCLUDE_DIR
    NAMES
      rtrlib/rtrlib.h
    PATHS
      /usr/include
      /usr/local/include
      /opt/local/include
      /sw/include
  )

  find_library(RTR_LIBRARY
    NAMES
      rtr
    PATHS
      /usr/lib
      /usr/local/lib
      /opt/local/lib
      /sw/lib
  )

  set(RTR_INCLUDE_DIRS
    ${RTR_INCLUDE_DIR}
  )

  if (RTR_LIBRARY)
    set(RTR_LIBRARIES
        ${RTR_LIBRARIES}
        ${RTR_LIBRARY}
    )
  endif (RTR_LIBRARY)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(RTR DEFAULT_MSG RTR_LIBRARIES RTR_INCLUDE_DIRS)

  # show the RTR_INCLUDE_DIRS and RTR_LIBRARIES variables only in the advanced view
  mark_as_advanced(RTR_INCLUDE_DIRS RTR_LIBRARIES)

endif (RTR_LIBRARIES AND RTR_INCLUDE_DIRS)
