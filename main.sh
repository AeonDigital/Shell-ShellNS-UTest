#!/usr/bin/env bash

#
# Selects all the files that are part of the package and fills the indicated
# array with the full path with each one.
#
# @param array $1
# Name of the array that will be populated with the files that are part of
# the package.
#
# @param string $2
# Type of execution.
# Choose one of : load, export, utests
#
# @return array
shellNS_main_select_package_files() {
  local -n arrTargetFiles="${1}"
  local strExecType="${2}"
  local tmpIterator=""



  #
  # If you are mounting a standalone version
  if [ "${strExecType}" == "export" ]; then
    local tgtDir="${SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH}"
    if [ -f "${tgtDir}/config.sh" ] && [ -f "${tgtDir}/dialog.sh" ] && [ -f "${tgtDir}/dependencies.sh" ] && [ -f "${tgtDir}/autoexec.sh" ]; then
      arrTargetFiles+=("${tgtDir}/config.sh")
      arrTargetFiles+=("${tgtDir}/dialog.sh")
      arrTargetFiles+=("${tgtDir}/dependencies.sh")
      arrTargetFiles+=("${tgtDir}/autoexec.sh")
    fi
  fi



  #
  # Get all unit tests in this package.
  if [ "${strExecType}" == "utest" ]; then
    for tmpIterator in $(find "${SHELLNS_TMP_MAIN_DIR_PATH}" -name "*_test.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done
  fi



  #
  # Checks for dependencies on specific functions
  if [ -d "${SHELLNS_TMP_MAIN_DIR_PATH}/_" ]; then
    for tmpIterator in $(find "${SHELLNS_TMP_MAIN_DIR_PATH}/_" -type f -name "*.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done
  fi

  #
  # Check for 'config.sh' file
  if [ -f "${SHELLNS_TMP_MAIN_DIR_PATH}/config.sh" ]; then
    arrTargetFiles+=("${SHELLNS_TMP_MAIN_DIR_PATH}/config.sh")
  fi

  #
  # Get 'config.sh' files
  if [ -d "${SHELLNS_TMP_MAIN_DIR_PATH}/src" ]; then
    for tmpIterator in $(find "${SHELLNS_TMP_MAIN_DIR_PATH}/src" -type f -name "config.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done

    #
    # Grab the rest of the files.
    for tmpIterator in $(find "${SHELLNS_TMP_MAIN_DIR_PATH}/src" -type f -name "*.sh" ! -name "config.sh" ! -name "*_test.sh"); do
      arrTargetFiles+=("${tmpIterator}")
    done
  fi



  #
  # Load the locale labels and adjusts
  local strFullPathToLocaleFile="${SHELLNS_TMP_MAIN_DIR_PATH}/locale/${SHELLNS_CONFIG_INTERFACE_LOCALE}.sh"
  if [ -f "${strFullPathToLocaleFile}" ]; then
    arrTargetFiles+=("${strFullPathToLocaleFile}")
  fi
}



#
# Execute the target function from target script.
#
# @param file $1
# Path to target script.
#
# @param function $2
# Name of the target function.
#
# @return mixed
shellNS_main_execute_script() {
  local tgtFile="${1}"
  local tgtFunctionName="${2}"
  shift
  shift

  if [ ! -f "${tgtFile}" ]; then
    local strMsg=""
    strMsg+="Script file does not exist.\n"
    strMsg+="**${tgtFile}**"

    shellNS_standalone_install_dialog "error" "${strMsg}"
    return 1
  fi

  . "${tgtFile}"
  $tgtFunctionName "$@"
  SHELLNS_MAIN_EXECUTE_SCRIPT_STATUS="$?"
  unset "${tgtFunctionName}"
}



#
# Loads the dependencies and starts the package in the context of the shell.
#
# @param bool $1
# When '1' will run this package in 'local' mode and therefore will download
# all dependencies.
#
# @return void
shellNS_main_load() {
  if [ "${1}" == "1" ]; then
    shellNS_standalone_install_dependencies "1"
  fi

  local -a arrayPackageFiles=()
  shellNS_main_select_package_files "arrayPackageFiles" "load"

  local pathToTargetFile=""
  for pathToTargetFile in "${arrayPackageFiles[@]}"; do
    . "${pathToTargetFile}"
  done
}




#
# Starts this package in the context of the shell.
#
# @param string $1
# Type of execution.
# Choose one of : export, utest, load
#
# @return void
shellNS_main_entrypoint() {
  #
  # Prepare entrypoint context
  unset SHELLNS_STANDALONE_LOAD_STATUS
  declare -gA SHELLNS_STANDALONE_LOAD_STATUS

  declare -g SHELLNS_MAIN_EXECUTE_SCRIPT_STATUS=""

  declare -g SHELLNS_TMP_MAIN_DIR_PATH="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}")"
  declare -g SHELLNS_TMP_STANDALONE_DIR_PATH="${SHELLNS_TMP_MAIN_DIR_PATH}/standalone"
  declare -g SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH="${SHELLNS_TMP_MAIN_DIR_PATH}/standalone/install"

  . "${SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH}/config.sh"
  . "${SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH}/dialog.sh"
  . "${SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH}/dependencies.sh"



  case "${1}" in
    "run")
      shellNS_main_load "1"
      ;;


    "install")
      shellNS_main_execute_script "standalone/install.sh" "shellNS_standalone_install" "install"
      ;;

    "uninstall")
      shellNS_main_execute_script "standalone/uninstall.sh" "shellNS_standalone_uninstall" "uninstall"
      ;;

    "update")
      shellNS_main_execute_script "standalone/uninstall.sh" "shellNS_standalone_uninstall" "update"
      if [ "${SHELLNS_MAIN_EXECUTE_SCRIPT_STATUS}" == "0" ]; then
        unset SHELLNS_STANDALONE_DEPENDENCIES["shellns_utest_standalone.sh"]
        shellNS_main_execute_script "standalone/install.sh" "shellNS_standalone_install" "update"
      fi
      ;;


    "utest")
      shellNS_main_execute_script "standalone/install.sh" "shellNS_standalone_install" "install" "1" "1"
      shellNS_main_execute_script "utest/execute.sh" "shellNS_utest_execute" "${2}" "${3}" "${4}"
      ;;


    "export")
      shellNS_main_execute_script "standalone/export.sh" "shellNS_standalone_export"
      ;;


    *)
      shellNS_main_load
      ;;
  esac



  #
  # Dispose entrypoint context
  unset shellNS_standalone_install_set_dependency
  unset shellNS_standalone_install_dependencies
  unset shellNS_standalone_install_dialog
  unset SHELLNS_STANDALONE_DEPENDENCIES

  unset SHELLNS_TMP_MAIN_DIR_PATH
  unset SHELLNS_TMP_STANDALONE_DIR_PATH
  unset SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH

  unset shellNS_main_select_package_files
  unset shellNS_main_execute_script
  unset shellNS_main_entrypoint
  unset shellNS_main_load
}


shellNS_main_entrypoint "${1}" "${2}" "${3}" "${4}"