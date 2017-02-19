#! /bin/bash

ETC_CONF_FILE="/etc/7daystodie.conf"

# Make sure the config file exist in /etc
if [ ! -f "${ETC_CONF_FILE}" ]; then
  echo "${ETC_CONF_FILE} does not exist."
  exit 1
fi

source "${ETC_CONF_FILE}"

check_user(){
  # Make sure we are running as the steam user
  if [ "$(whoami)" != "${CONF_STEAM_USER}" ]; then
    echo "Please run with ${CONF_STEAM_USER} user"
    exit 1
  fi

  # steam user should not be root
  if [ "${EUID}" -eq "0" ]; then
    echo "Please do not use root user as the steam user"
    exit 1
  fi
}

do_full_backup(){
  check_user
  force_save
  sleep 1
  
  # rm ${CONF_GAME_BACKUP_SNAPSHOT_FILE}
  local tar_file="${CONF_GAME_PATH_BACKUPS}/${CONF_GAME_BACKUP_FULL_PREFIX}$(date +${CONF_GAME_BACKUP_DATE_FORMAT}).tar.gz"
  tar --create \
      --verbose \
      --gzip \
      --file="${tar_file}" \
      --listed-incremental="${CONF_GAME_BACKUP_SNAPSHOT_FILE}" \
      --level=0 \
      "${CONF_GAME_PATH_SAVES}"
}

do_diff_backup(){
  check_user
  if [ -r "${CONF_GAME_BACKUP_SNAPSHOT_FILE}" ]; then
    force_save
    cp "${CONF_GAME_BACKUP_SNAPSHOT_FILE}" "${CONF_GAME_BACKUP_SNAPSHOT_FILE}_diff"
    sleep 1
    local tar_file="${CONF_GAME_PATH_BACKUPS}/${CONF_GAME_BACKUP_DIFF_PREFIX}$(date +${CONF_GAME_BACKUP_DATE_FORMAT}).tar.gz"
    tar --create \
        --verbose \
        --gzip \
        --file="${tar_file}" \
        --listed-incremental="${CONF_GAME_BACKUP_SNAPSHOT_FILE}_diff" \
        --level=1 \
        "${CONF_GAME_PATH_SAVES}"
    rm "${CONF_GAME_BACKUP_SNAPSHOT_FILE}_diff"
  else
    do_full_backup
  fi
}

start_server() {
  check_user

  log_file="${CONF_GAME_PATH_LOGS}/${CONF_GAME_LOG_PREFIX}$(date +${CONF_GAME_LOG_DATE_FORMAT})${CONF_GAME_LOG_EXTENSTION}"
  run_parameters="-logfile ${log_file} -quit -batchmode -nographics -dedicated -configfile=${CONF_GAME_FILE_SERVER_CONFIG}"
  export LD_LIBRARY_PATH="${CONF_GAME_PATH_APPLICATION}"

  #export MALLOC_CHECK_=0

  echo "Starting server with log: ${log_file}"
  echo " and parameters: ${run_parameters}"
  if [ "$(uname -m)" = "x86_64" ]; then
          ${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86_64 ${run_parameters}
  else
          ${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86 ${run_parameters}
  fi

  # Wait a sec to allow file to be closed then compress
  sleep 1
  /bin/gzip -9 "${log_file}"
}

telnet_command() {
  ( echo $1 ; sleep .1 ; echo exit ) \
      | nc localhost "${CONF_GAME_TELNET_PORT}"
}

get_player_count() {
  telnet_command "listplayers" \
      | egrep 'Total of .+ in the game' \
      | cut -d ' ' -f3
}

force_save(){
  telnet_command "saveworld"
}


