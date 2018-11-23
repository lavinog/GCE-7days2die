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

telnet_command "say System shutdown request occured."
telnet_command "say The server will be shutting down in 10 seconds."
sleep 10
telnet_command "saveworld"
telnet_command "say Shutting down server now."
sleep 1
telnet_command "shutdown"
sleep 3
