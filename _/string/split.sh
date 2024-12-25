#!/usr/bin/env bash

#
# Splits the string into an array using the indicated separator.
#
# @param array $1
# Name of the array that will be populated with the processing result.
#
# @param string $2
# Separator.
#
# @param string $3
# Original string (which will be splited).
#
# @param ?bool $4
# ::
#   - default : "0"
#   - list    : SHELLNS_PROMPT_OPTION_BOOL
# ::
# Indicates when empty values should be kept in the resulting array.
#
# @param ?bool $5
# ::
#   - default : "0"
#   - list    : SHELLNS_PROMPT_OPTION_BOOL
# ::
# indicates when to perform a **trim** on each of the values found.
#
# @return array
shellNS_string_split() {
  if [ "$#" -ge "3" ]; then
    declare -n arrTargetArray="${1}"
    arrTargetArray=()

    local strSeparator="${2}"
    local strString="${3}"
    local strSubStr=""
    local boolRemoveEmpty=$(shellNS_var_get "${4}" "0" "0 1")
    local boolTrimElements=$(shellNS_var_get "${5}" "0" "0 1")


    local mseLastChar=""

    while [ "${strString}" != "" ]; do
      if [[ "${strString}" != *"${strSeparator}"* ]]; then
        if [ "${boolTrimElements}" == "1" ]; then
          strString=$(shellNS_string_trim "${strString}")
        fi
        arrTargetArray+=("${strString}")
        break
      else
        strSubStr="${strString%%${strSeparator}*}"
        if [ "${strSubStr}" == "" ] && [ "${strSeparator}" == " " ]; then
          strSubStr=" "
        fi
        mseLastChar="${strString: -1}"

        if [ "${boolTrimElements}" == "1" ]; then
          strSubStr=$(shellNS_string_trim "${strSubStr}")
        fi

        if [ "${strSubStr}" != "" ] || [ "${boolRemoveEmpty}" == "0" ]; then
          arrTargetArray+=("${strSubStr}")
        fi

        strString="${strString#*${strSeparator}}"
        if [ "${strString}" == "" ] && [ "${mseLastChar}" == "${strSeparator}" ] && [ "${boolRemoveEmpty}" == "0" ]; then
          arrTargetArray+=("")
        fi
      fi
    done
  fi
}