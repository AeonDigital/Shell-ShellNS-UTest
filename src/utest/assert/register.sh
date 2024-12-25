#!/usr/bin/env bash

#
# Records the count of a unit test and displays its result.
#
# @return string
shellNS_utest_assert_register() {
  ((utestFunctionCountAssert++))
  ((SHELLNS_UTEST_COUNT_TESTS_ASSERTATIONS++))


  local strMsg=""
  local strMsgType=""

  if [ "${utestTestIsSuccess}" == "1" ]; then
    ((SHELLNS_UTEST_COUNT_TESTS_SUCCESS++))

    strMsgType="ok"
    strMsg+="${utestFunctionCountAssert} OK"
  else
    ((SHELLNS_UTEST_COUNT_TESTS_FAIL++))

    strMsgType="fail"
    strMsg+="${utestFunctionCountAssert} FAIL\n"
    strMsg+="Result    : ${utestTestResult}\n"
    strMsg+="Expected  : ${utestTestExpected}"
  fi

  shellNS_dialog_set "${strMsgType}" "${strMsg}"
  shellNS_dialog_show
  shellNS_dialog_reset
}