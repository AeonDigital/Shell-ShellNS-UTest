#!/usr/bin/env bash

#
# Exports a **package.sh** file containing this all the package code.
#
# @return status+string
shellNS_standalone_export() {
  local -a arrayExportFiles=()
  shellNS_main_select_package_files "arrayExportFiles" "export"


  local codeNL=$'\n'
  local strFileContent=""
  local strFileStandalone="#!/usr/bin/env bash${codeNL}${codeNL}"

  local strRawLine=""
  local strCleanLine=""


  local pathToTargetFile=""
  for pathToTargetFile in "${arrayExportFiles[@]}"; do
    strFileContent=$(< "${pathToTargetFile}")

    IFS=$'\n'
    while read -r strRawLine || [ -n "${strRawLine}" ]; do
      strCleanLine="${strRawLine}"
      strCleanLine="${strCleanLine#"${strCleanLine%%[![:space:]]*}"}" # trim L
      strCleanLine="${strCleanLine%"${strCleanLine##*[![:space:]]}"}" # trim R
      if [ "${strCleanLine}" != "" ] && [ "${strCleanLine:0:1}" != "#" ]; then
        strFileStandalone+="${strRawLine}${codeNL}"
      fi
    done <<< "${strFileContent}"
    unset IFS
  done


  strFileStandalone="${strFileStandalone#"${strFileStandalone%%[![:space:]]*}"}" # trim L
  strFileStandalone="${strFileStandalone%"${strFileStandalone##*[![:space:]]}"}" # trim R
  echo "${strFileStandalone}" > "standalone/package.sh"
  if [ "$?" != "0" ]; then
    shellNS_standalone_install_dialog "error" "Error on create 'standalone/package.sh' file."
  fi
  shellNS_standalone_install_dialog "ok" "File 'standalone/package.sh' created."
  return 0
}