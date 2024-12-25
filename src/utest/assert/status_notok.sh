#!/usr/bin/env bash

#
# Checks if the value of **utestTestResult** is non-zero (failed).  
# These variables must be defined in a scope greater than this function.
#
# @return string
shellNS_utest_assert_status_notok() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" != "0" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}