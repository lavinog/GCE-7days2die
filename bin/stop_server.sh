#! /bin/bash

# Stops running 7 Days to Die Server
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

telnet_command "shutdown"
sleep 2
