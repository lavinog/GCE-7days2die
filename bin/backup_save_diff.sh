#! /bin/bash

# Performs backup of 7 Days to Die World
#
#

ETC_CONF_FILE="/etc/7daystodie.conf"

# Make sure the config file exist in /etc
if [ ! -f "${ETC_CONF_FILE}" ]; then
  echo "${ETC_CONF_FILE} does not exist."
  exit 1
fi

source "${ETC_CONF_FILE}"
source "${CONF_GAME_FILE_FUNCTION_LIB}"

do_diff_backup
