#!/usr/bin/env bash

#
# Checks that the value of the **utestTestResult** and **utestTestExpected**
# variables are the same.
# These variables must be defined in a scope greater than this function.
#
# @return string
shellNS_utest_assert_equal() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "${utestTestExpected}" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}