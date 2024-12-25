#!/usr/bin/env bash

if [[ "$(declare -p "SHELLNS_STANDALONE_LOAD_STATUS" 2> /dev/null)" != "declare -A"* ]]; then
  declare -gA SHELLNS_STANDALONE_LOAD_STATUS
fi
SHELLNS_STANDALONE_LOAD_STATUS["shellns_utest_standalone.sh"]="ready"
unset SHELLNS_STANDALONE_DEPENDENCIES
declare -gA SHELLNS_STANDALONE_DEPENDENCIES
shellNS_standalone_install_set_dependency() {
  local strDownloadFileName="shellns_${2,,}_standalone.sh"
  local strPkgStandaloneURL="https://raw.githubusercontent.com/AeonDigital/${1}/refs/heads/main/standalone/package.sh"
  SHELLNS_STANDALONE_DEPENDENCIES["${strDownloadFileName}"]="${strPkgStandaloneURL}"
}
shellNS_standalone_install_set_dependency "Shell-ShellNS-Dialog" "dialog"
declare -gA SHELLNS_DIALOG_TYPE_COLOR=(
  ["raw"]=""
  ["info"]="\e[1;34m"
  ["warning"]="\e[0;93m"
  ["error"]="\e[1;31m"
  ["question"]="\e[1;35m"
  ["input"]="\e[1;36m"
  ["ok"]="\e[20;49;32m"
  ["fail"]="\e[20;49;31m"
)
declare -gA SHELLNS_DIALOG_TYPE_PREFIX=(
  ["raw"]=" - "
  ["info"]="inf"
  ["warning"]="war"
  ["error"]="err"
  ["question"]=" ? "
  ["input"]=" < "
  ["ok"]=" v "
  ["fail"]=" x "
)
declare -g SHELLNS_DIALOG_PROMPT_INPUT=""
shellNS_standalone_install_dialog() {
  local strDialogType="${1}"
  local strDialogMessage="${2}"
  local boolDialogWithPrompt="${3}"
  local codeColorPrefix="${SHELLNS_DIALOG_TYPE_COLOR["${strDialogType}"]}"
  local strMessagePrefix="${SHELLNS_DIALOG_TYPE_PREFIX[${strDialogType}]}"
  if [ "${strDialogMessage}" != "" ] && [ "${codeColorPrefix}" != "" ] && [ "${strMessagePrefix}" != "" ]; then
    local strIndent="        "
    local strPromptPrefix="      > "
    local codeColorNone="\e[0m"
    local codeColorText="\e[0;49m"
    local codeColorHighlight="\e[1;49m"
    local tmpCount="0"
    while [[ "${strDialogMessage}" =~ "**" ]]; do
      ((tmpCount++))
      if (( tmpCount % 2 != 0 )); then
        strDialogMessage="${strDialogMessage/\*\*/${codeColorHighlight}}"
      else
        strDialogMessage="${strDialogMessage/\*\*/${codeColorNone}}"
      fi
    done
    local codeNL=$'\n'
    strDialogMessage=$(echo -ne "${strDialogMessage}")
    strDialogMessage="${strDialogMessage//${codeNL}/${codeNL}${strIndent}}"
    local strShowMessage=""
    strShowMessage+="[ ${codeColorPrefix}${strMessagePrefix}${codeColorNone} ] "
    strShowMessage+="${codeColorText}${strDialogMessage}${codeColorNone}\n"
    echo -ne "${strShowMessage}"
    if [ "${boolDialogWithPrompt}" == "1" ]; then
      SHELLNS_DIALOG_PROMPT_INPUT=""
      read -r -p "${strPromptPrefix}" SHELLNS_DIALOG_PROMPT_INPUT
    fi
  fi
  return 0
}
shellNS_standalone_install_dependencies() {
  if [[ "$(declare -p "SHELLNS_STANDALONE_DEPENDENCIES" 2> /dev/null)" != "declare -A"* ]]; then
    return 0
  fi
  if [ "${#SHELLNS_STANDALONE_DEPENDENCIES[@]}" == "0" ]; then
    return 0
  fi
  local pkgFileName=""
  local pkgSourceURL=""
  local pgkLoadStatus=""
  for pkgFileName in "${!SHELLNS_STANDALONE_DEPENDENCIES[@]}"; do
    pgkLoadStatus="${SHELLNS_STANDALONE_LOAD_STATUS[${pkgFileName}]}"
    if [ "${pgkLoadStatus}" == "" ]; then pgkLoadStatus="0"; fi
    if [ "${pgkLoadStatus}" == "ready" ] || [ "${pgkLoadStatus}" -ge "1" ]; then
      continue
    fi
    if [ ! -f "${pkgFileName}" ]; then
      pkgSourceURL="${SHELLNS_STANDALONE_DEPENDENCIES[${pkgFileName}]}"
      curl -o "${pkgFileName}" "${pkgSourceURL}"
      if [ ! -f "${pkgFileName}" ]; then
        local strMsg=""
        strMsg+="An error occurred while downloading a dependency.\n"
        strMsg+="URL: **${pkgSourceURL}**\n\n"
        strMsg+="This execution was aborted."
        shellNS_standalone_install_dialog "error" "${strMsg}"
        return 1
      fi
    fi
    chmod +x "${pkgFileName}"
    if [ "$?" != "0" ]; then
      local strMsg=""
      strMsg+="Could not give execute permission to script:\n"
      strMsg+="FILE: **${pkgFileName}**\n\n"
      strMsg+="This execution was aborted."
      shellNS_standalone_install_dialog "error" "${strMsg}"
      return 1
    fi
    SHELLNS_STANDALONE_LOAD_STATUS["${pkgFileName}"]="1"
  done
  if [ "${1}" == "1" ]; then
    for pkgFileName in "${!SHELLNS_STANDALONE_DEPENDENCIES[@]}"; do
      pgkLoadStatus="${SHELLNS_STANDALONE_LOAD_STATUS[${pkgFileName}]}"
      if [ "${pgkLoadStatus}" == "ready" ]; then
        continue
      fi
      . "${pkgFileName}"
      if [ "$?" != "0" ]; then
        local strMsg=""
        strMsg+="An unexpected error occurred while load script:\n"
        strMsg+="FILE: **${pkgFileName}**\n\n"
        strMsg+="This execution was aborted."
        shellNS_standalone_install_dialog "error" "${strMsg}"
        return 1
      fi
      SHELLNS_STANDALONE_LOAD_STATUS["${pkgFileName}"]="ready"
    done
  fi
}
shellNS_standalone_install_dependencies "1"
unset shellNS_standalone_install_set_dependency
unset shellNS_standalone_install_dependencies
unset shellNS_standalone_install_dialog
unset SHELLNS_STANDALONE_DEPENDENCIES
unset SHELLNS_UTEST_MAIN_MAPPING
declare -gA SHELLNS_UTEST_MAIN_MAPPING
SHELLNS_UTEST_CURRENT_PACKAGE=""
SHELLNS_UTEST_CURRENT_FUNCTION=""
SHELLNS_UTEST_COUNT_TESTS_FUNCTION="0"
SHELLNS_UTEST_COUNT_TESTS_ASSERTATIONS="0"
SHELLNS_UTEST_COUNT_TESTS_SUCCESS="0"
SHELLNS_UTEST_COUNT_TESTS_FAIL="0"
shellNS_utest_register() {
  local strPackageName=$(shellNS_string_trim "${1}")
  local strTestedFunction=$(shellNS_string_trim "${2}")
  local strUnitTestFunction=$(shellNS_string_trim "${3}")
  if [ "${strPackageName}" != "" ] && [ "${strTestedFunction}" != "" ] && [ "${strUnitTestFunction}" != "" ]; then
    local strRegister="pkg:${strPackageName};fn:${strTestedFunction};"
    SHELLNS_UTEST_MAIN_MAPPING["${strRegister}"]="${strUnitTestFunction}"
  fi
}
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
shellNS_utest_assert_status_ok() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "0" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}
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
shellNS_utest_assert_bool_false() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "0" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}
shellNS_utest_assert_equal() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "${utestTestExpected}" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}
shellNS_utest_assert_status_notok() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" != "0" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}
shellNS_utest_assert_bool_true() {
  utestTestIsSuccess="0"
  if [ "${utestTestResult}" == "1" ]; then
    utestTestIsSuccess="1"
  fi
  shellNS_utest_assert_register
}
SHELLNS_TMP_PATH_TO_DIR_MANUALS="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}/src-manuals/${SHELLNS_CONFIG_INTERFACE_LOCALE}")"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_bool_false"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/bool_false.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_bool_true"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/bool_true.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_equal"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/equal.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_register"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/register.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_status_notok"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/status_notok.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_status_ok"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/status_ok.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_register"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/register.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_start"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/start.man"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.bool.false"]="shellNS_utest_assert_bool_false"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.bool.true"]="shellNS_utest_assert_bool_true"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.equal"]="shellNS_utest_assert_equal"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.register"]="shellNS_utest_assert_register"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.status.notok"]="shellNS_utest_assert_status_notok"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.status.ok"]="shellNS_utest_assert_status_ok"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.register"]="shellNS_utest_register"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.start"]="shellNS_utest_start"
unset SHELLNS_TMP_PATH_TO_DIR_MANUALS
