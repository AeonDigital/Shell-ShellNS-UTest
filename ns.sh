#!/usr/bin/env bash

#
# Get path to the manuals directory.
SHELLNS_TMP_PATH_TO_DIR_MANUALS="$(tmpPath=$(dirname "${BASH_SOURCE[0]}"); realpath "${tmpPath}/src-manuals/${SHELLNS_CONFIG_INTERFACE_LOCALE}")"


#
# Mapp function to manual.
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_bool_false"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/bool_false.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_bool_true"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/bool_true.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_equal"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/equal.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_register"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/register.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_status_notok"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/status_notok.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_assert_status_ok"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/assert/status_ok.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_register"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/register.man"
SHELLNS_MAPP_FUNCTION_TO_MANUAL["shellNS_utest_start"]="${SHELLNS_TMP_PATH_TO_DIR_MANUALS}/utest/start.man"


#
# Mapp namespace to function.
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.bool.false"]="shellNS_utest_assert_bool_false"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.bool.true"]="shellNS_utest_assert_bool_true"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.equal"]="shellNS_utest_assert_equal"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.register"]="shellNS_utest_assert_register"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.status.notok"]="shellNS_utest_assert_status_notok"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.assert.status.ok"]="shellNS_utest_assert_status_ok"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.register"]="shellNS_utest_register"
SHELLNS_MAPP_NAMESPACE_TO_FUNCTION["utest.start"]="shellNS_utest_start"





unset SHELLNS_TMP_PATH_TO_DIR_MANUALS