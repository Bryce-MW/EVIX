# CMake generated Testfile for 
# Source directory: /evix/rtrlib-0.3.6
# Build directory: /evix/rtrlib-0.3.6
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(test_pfx "tests/test_pfx")
add_test(test_lpfst "tests/test_lpfst")
add_test(test_pfx_locks "tests/test_pfx_locks")
add_test(test_ht_spkitable "tests/test_ht_spkitable")
add_test(test_ht_spkitable_locks "tests/test_ht_spkitable_locks")
subdirs(tools)
subdirs(doxygen/examples)
subdirs(tests)
