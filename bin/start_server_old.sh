#! /bin/bash

. /etc/7daystodie.conf

# Verify that the correct user is calling script

if [ "${USER}" != "${CONF_STEAM_USER}" ]
then
  echo "Please run with ${CONF_STEAM_USER} user"
  exit 1
fi

LOGFILE="${CONF_GAME_PATH_LOG}/${CONF_GAME_LOG_PREFIX}$(date +${CONF_GAME_LOG_DATE_FORMAT})${CONF_GAME_LOG_EXTENSTION}"

PARAMS="-logfile ${LOGFILE} -quit -batchmode -nographics -dedicated -configfile=${CONF_GAME_FILE_SERVER_CONFIG}"

echo "Starting server with log: ${LOGFILE}"

# cd "${CONF_GAME_PATH_APPLICATION}"

export LD_LIBRARY_PATH="${CONF_GAME_PATH_APPLICATION}"

#export MALLOC_CHECK_=0

if [ "$(uname -m)" = "x86_64" ]; then
	${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86_64 $PARAMS
else
	${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86 $PARAMS
fi

# Wait a sec to allow file to be closed then compress
sleep 1
gzip -9 ${LOGFILE}
