#!/usr/bin/env bash

#
# Checks if the value of **utestTestResult** is equal to **1** (true).  
# These variables must be defined in a scope greater than this function.
#
# @return string
shellNS_utest_assert_bool_true() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "1" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}