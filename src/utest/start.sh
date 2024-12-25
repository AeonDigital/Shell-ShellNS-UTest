#!/usr/bin/env bash

#
# Runs the entire unit tests battery.
#
# @param ?bool $1
# ::
#   - default : "0"
#   - list    : SHELLNS_PROMPT_OPTION_BOOL
# ::
# Stop tests on the first fail.
#
# @param ?string[,] $2
# If informed, it will only run the tests referring to the informed packages.
#
# @param ?string[,] $3
# If informed, it will only run the tests referring to the informed functions.
#
# @return string
# Prints the result of all the tests performed.
shellNS_utest_start() {
  local tmpIterator=""
  local tmpUnitTestScript=""
  local tmpPathToInstalledPackage=""


  local boolStopOnError="0"
  local strStopOnError="no"
  if [ "${1}" == "1" ]; then boolStopOnError="1"; strStopOnError="yes"; fi

  local -a arrTargetPackages=()
  if [ "${2}" != "" ]; then
    shellNS_string_split "arrTargetPackages" "," "${2}" "0" "1"
  fi

  local -a arrTargetFunctions=()
  if [ "${3}" != "" ]; then
    shellNS_string_split "arrTargetFunctions" "," "${3}" "0" "1"
  fi



  local -a arrSelectedUnitTestByPackage
  local -a arrSelectedUnitTestByFunction
  local tmpUnitTestMapping=""
  local tmpTargetObject=""
  local tmpMatch=""



  if [ "${#arrTargetPackages[@]}" == "0" ]; then
    for tmpUnitTestMapping in "${!SHELLNS_UTEST_MAIN_MAPPING[@]}"; do
      arrSelectedUnitTestByPackage+=("${tmpUnitTestMapping}")
    done
  else
    for tmpUnitTestMapping in "${!SHELLNS_UTEST_MAIN_MAPPING[@]}"; do
      for tmpTargetObject in "${arrTargetPackages[@]}"; do
        tmpMatch="pkg:${tmpTargetObject};"
        if [[ "${tmpUnitTestMapping}" == *"${tmpMatch}"* ]]; then
          arrSelectedUnitTestByPackage+=("${tmpUnitTestMapping}")
        fi
      done
    done
  fi



  if [ "${#arrTargetFunctions[@]}" == "0" ]; then
    for tmpUnitTestMapping in "${arrSelectedUnitTestByPackage[@]}"; do
      arrSelectedUnitTestByFunction+=("${tmpUnitTestMapping}")
    done
  else
    for tmpUnitTestMapping in "${arrSelectedUnitTestByPackage[@]}"; do
      for tmpTargetObject in "${arrTargetFunctions[@]}"; do
        tmpMatch="fn:${tmpTargetObject};"

        if [[ "${tmpUnitTestMapping}" == *"${tmpMatch}"* ]]; then
          arrSelectedUnitTestByFunction+=("${tmpUnitTestMapping}")
        fi
      done
    done
  fi




  if [ "${#arrSelectedUnitTestByFunction[@]}" == "0" ]; then
    shellNS_dialog_set "fail" "No test was found for the reported criteria"
    shellNS_dialog_show
    return 1
  fi

  #
  # Order tests
  arrSelectedUnitTestByFunction=($(for tmpUnitTestMapping in "${arrSelectedUnitTestByFunction[@]}"; do echo "${tmpUnitTestMapping}"; done | sort))


  local tmpMapp=""
  local tmpLastHeader=""
  local strPackageName=""
  local strTestedFunction=""
  local strIntTestedFunction=""
  local strUnitTestFunction=""

  local intTotalTestedFunctions="${#arrSelectedUnitTestByFunction[@]}"


  echo "# Starting unit tests"
  echo "  Total         : ${intTotalTestedFunctions}"
  echo "  Stop on error : ${strStopOnError}"

  SHELLNS_UTEST_CURRENT_PACKAGE=""
  SHELLNS_UTEST_CURRENT_FUNCTION=""
  SHELLNS_UTEST_COUNT_TESTS_FUNCTION="0"
  SHELLNS_UTEST_COUNT_TESTS_ASSERTATIONS="0"
  SHELLNS_UTEST_COUNT_TESTS_SUCCESS="0"
  SHELLNS_UTEST_COUNT_TESTS_FAIL="0"


  local utestTestIsSuccess=""
  local utestTestResult=""
  local utestTestExpected=""
  local utestFunctionCountAssert="0"

  for tmpUnitTestMapping in "${arrSelectedUnitTestByFunction[@]}"; do
    ((SHELLNS_UTEST_COUNT_TESTS_FUNCTION++))
    utestTestIsSuccess=""
    utestTestResult=""
    utestTestExpected=""
    utestFunctionCountAssert="0"


    tmpMapp="${tmpUnitTestMapping:: -1}"

    strPackageName="${tmpMapp%%;*}"
    strPackageName="${strPackageName#*:}"

    strTestedFunction="${tmpMapp##*;}"
    strTestedFunction="${strTestedFunction#*:}"

    strUnitTestFunction="${SHELLNS_UTEST_MAIN_MAPPING["${tmpUnitTestMapping}"]}"

    if [ "${SHELLNS_UTEST_CURRENT_PACKAGE}" != "${strPackageName}" ]; then
      SHELLNS_UTEST_CURRENT_PACKAGE="${strPackageName}"
      echo ""
      echo ""
      echo "## Package ${strPackageName}"
      tmpLastHeader="Package"
    fi

    if [ "${SHELLNS_UTEST_CURRENT_FUNCTION}" != "${strTestedFunction}" ]; then
      SHELLNS_UTEST_CURRENT_FUNCTION="${strTestedFunction}"
      if [ "${tmpLastHeader}" == "Function" ]; then
        echo ""
        echo ""
      fi

      strIntTestedFunction="${SHELLNS_UTEST_COUNT_TESTS_FUNCTION}"
      while [ "${#strIntTestedFunction}" -lt "${#intTotalTestedFunctions}" ]; do
        strIntTestedFunction="0${strIntTestedFunction}"
      done

      echo "### [ ${strIntTestedFunction} ] Function ${strTestedFunction}"
      tmpLastHeader="Function"
    fi

    ${strUnitTestFunction}

    if [ "${boolStopOnError}" == "1" ] && [ "${SHELLNS_UTEST_COUNT_TESTS_FAIL}" -gt "0" ]; then
      echo ""
      echo ">>> STOPPED AT FIRST ERROR"
      break
    fi
  done


  local strUnitTestSummary="\n\n"
  strUnitTestSummary+="# Unit test summary\n"
  strUnitTestSummary+=":: Tested functions  : ${SHELLNS_UTEST_COUNT_TESTS_FUNCTION}\n"
  strUnitTestSummary+=":: Assertations      : ${SHELLNS_UTEST_COUNT_TESTS_ASSERTATIONS}\n"
  strUnitTestSummary+=":: Success           : ${SHELLNS_UTEST_COUNT_TESTS_SUCCESS}\n"
  strUnitTestSummary+=":: Failed            : ${SHELLNS_UTEST_COUNT_TESTS_FAIL}\n"
  echo -e "${strUnitTestSummary}"
}