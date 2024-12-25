#!/usr/bin/env bash

#
# Package Config


#
# Unit Test Function Map
unset SHELLNS_UTEST_MAIN_MAPPING
declare -gA SHELLNS_UTEST_MAIN_MAPPING



#
# Current package being tested
SHELLNS_UTEST_CURRENT_PACKAGE=""
#
# Current function being tested
SHELLNS_UTEST_CURRENT_FUNCTION=""
#
# Accounts for the total number of unit test functions that have been executed.
SHELLNS_UTEST_COUNT_TESTS_FUNCTION="0"
#
# Accounts for the total number of assertations that have been done across the
# entire battery of unit tests
SHELLNS_UTEST_COUNT_TESTS_ASSERTATIONS="0"
#
# Counts the total number of tests successfully done.
SHELLNS_UTEST_COUNT_TESTS_SUCCESS="0"
#
# Counts the total number of tests done that failed.
SHELLNS_UTEST_COUNT_TESTS_FAIL="0"