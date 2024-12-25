#!/usr/bin/env bash

#
# Checks if the value of **utestTestResult** is equal to zero (success).  
# These variables must be defined in a scope greater than this function.
#
# @return string
shellNS_utest_assert_status_ok() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "0" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}