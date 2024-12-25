#!/usr/bin/env bash

#
# Writes the data of a unit test so that it is part of the test battery.
#
# @param string $1
# Name of the package to which the unit test belongs.
#
# @param string $2
# Name of the tested function.
#
# @param string $3
# Name of the unit test function associated with the tested function.
#
# @return void
shellNS_utest_register() {
  local strPackageName=$(shellNS_string_trim "${1}")
  local strTestedFunction=$(shellNS_string_trim "${2}")
  local strUnitTestFunction=$(shellNS_string_trim "${3}")

  if [ "${strPackageName}" != "" ] && [ "${strTestedFunction}" != "" ] && [ "${strUnitTestFunction}" != "" ]; then
    local strRegister="pkg:${strPackageName};fn:${strTestedFunction};"
    SHELLNS_UTEST_MAIN_MAPPING["${strRegister}"]="${strUnitTestFunction}"
  fi
}