#!/usr/bin/env bash

#
# Installs the project dependencies locally.
#
# @param string $1
# Context in which this operation was evoked.
# [ install | update ]
#
# @param bool $2
# If **1** gets the **ShellNS-UTest** package.
#
# @param bool $3
# If **1** load all dependencies after download.
#
# @return status+string
shellNS_standalone_install() {
  local strMessageContentOk=""
  local strMessageContentError=""
  local isAutoLoadPendendencies="${3}"


  local strContext="${1}"
  if [ "${strContext}" != "install" ] && [ "${strContext}" != "update" ]; then
    local strMessageContent=""
    strMessageContent+="Invalid context [ '\$1' = '${strContext}' ]."
    strMessageContent+="Expected 'install' or 'update'."
    shellNS_standalone_install_dialog "error" "${strMessageContent}"
    return 1
  fi


  if [ "${strContext}" == "install" ]; then
    strMessageContentOk="Installation completed."
    strMessageContentError="Installation cannot be completed."
  else
    strMessageContentOk="Update completed."
    strMessageContentError="Update cannot be completed."
  fi


  if [ "${2}" == "1" ]; then
    shellNS_standalone_install_set_dependency "Shell-ShellNS-UTest" "utest"
  fi


  local intReturn="0"
  local strMessageType="ok"
  local strMessageContent="${strMessageContentOk}"

  shellNS_standalone_install_dependencies "${isAutoLoadPendendencies}"
  if [ "$?" != "0" ]; then
    intReturn="1"
    strMessageType="error"
    strMessageContent="${strMessageContentError}"
  fi

  . "${SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH}/dialog.sh"
  shellNS_standalone_install_dialog "${strMessageType}" "${strMessageContent}"
  return "${intReturn}"
}