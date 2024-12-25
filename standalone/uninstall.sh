#!/usr/bin/env bash

#
# Uninstall the project dependencies.
#
# @param string $1
# Context in which this operation was evoked.
# [ update | uninstall ]
#
# @return status+string
shellNS_standalone_uninstall() {
  local strMessageContentOk=""
  local strMessageContentError=""


  local strContext="${1}"
  if [ "${strContext}" != "update" ] && [ "${strContext}" != "uninstall" ]; then
    local strMessageContent=""
    strMessageContent+="Invalid context [ '\$1' = '${strContext}' ]."
    strMessageContent+="Expected 'update' or 'uninstall'."
    shellNS_standalone_install_dialog "error" "${strMessageContent}"
    return 1
  fi



  if [ "${strContext}" == "update" ]; then
    strMessageContentOk="Old files successfully removed."
    strMessageContentError="Update cannot be completed."
  else
    strMessageContentOk="Uninstall completed."
    strMessageContentError="Uninstall cannot be completed."
  fi
  local intReturn="0"
  local strMessageType="ok"
  local strMessageContent="${strMessageContentOk}"



  #
  # Get UTest package
  shellNS_standalone_install_set_dependency "Shell-ShellNS-UTest" "utest"

  local pkgFileName=""
  for pkgFileName in "${!SHELLNS_STANDALONE_DEPENDENCIES[@]}"; do
    if [ -f "${pkgFileName}" ]; then
      rm "${pkgFileName}"
      if [ -f "${pkgFileName}" ]; then
        intReturn="1"
        strMessageType="error"
        strMessageContent="Fail on remove file '${pkgFileName}'.\n${strMessageContentError}"
        break
      fi
    fi
  done

  . "${SHELLNS_TMP_STANDALONE_INSTALL_DIR_PATH}/dialog.sh"
  shellNS_standalone_install_dialog "${strMessageType}" "${strMessageContent}"
  return "${intReturn}"
}