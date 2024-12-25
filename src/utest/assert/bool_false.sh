#!/usr/bin/env bash

#
# Checks if the value of **utestTestResult** is equal to **0** (false).  
# These variables must be defined in a scope greater than this function.
#
# @return string
shellNS_utest_assert_bool_false() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "0" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}