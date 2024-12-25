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
shellNS_utest_execute() {
  local strTest="local evalResult=\"0\"; [ \"\$(type -t shellNS_utest_start)\" == \"function\" ] && echo 1"
  local isOk=$(eval "${strTest}")
  if [ "${isOk}" != "1" ]; then
    shellNS_standalone_install_dialog "error" "ShellNS-UTest not found!"
    return 1
  fi


  local -a arrayPackageFiles=()
  shellNS_main_select_package_files "arrayPackageFiles" "utest"


  local pathToTargetFile=""
  for pathToTargetFile in "${arrayPackageFiles[@]}"; do
    . "${pathToTargetFile}"
  done


  if [ "${#SHELLNS_UTEST_MAIN_MAPPING[@]}" == "0" ]; then
    shellNS_standalone_install_dialog "error" "No tests were found"
    return 1
  fi


  shellNS_utest_start "${1}" "${2}" "${3}"
}