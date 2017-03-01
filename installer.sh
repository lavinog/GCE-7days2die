#! /bin/bash
# Installs 7 days to die server on a linux server and configures management scripts
# Source can be found at https://github.com/lavinog/GCE-7days2die
#
# Following Google's bash style guide:
# https://google.github.io/styleguide/shell.xml

readonly E_CANCELLED=1
readonly E_ROLE_ADD_FAILED=2
readonly E_USER_GROUP_ADD_FAILED=3
readonly E_FAILED_TO_CREATE_PATH=4
readonly E_FAILED_TO_SET_PERMISSIONS=5


readonly CURRENT_CONF_FILE="./config/7daystodie.conf"
import "${CURRENT_CONF_FILE}"


#######################################
# Displays the config settings to the user and prompts to continue.
# Exits with E_CANCELLED if user presses anything but 'y'
# Globals:
#   CURRENT_CONF_FILE
# Arguments:
#   None
# Returns:
#   None
#######################################
show_warning() {
  echo  'This file will be installing a 7 days to die server with the following settings:'
  grep CONF "${CURRENT_CONF_FILE}"
  read -t30 -n1 -r -p 'Do you wish to continue? (y/n) ' KEY
  if [ "${KEY}" == "y" ]; then
      echo 'Installing'
  else
      echo 'Exiting.'
      exit ${E_CANCELLED}
  fi


#######################################
# Displays error message in red to stdout and stderr
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
err() {
  echo -e "\033[0;31m${1}\033[0m" 1>&2
}

#######################################
# Creates role account user and adds current user to role group
# Globals:
#   CONF_STEAM_USER
#   USER
# Arguments:
#   None
# Returns:
#   None
#######################################
create_role_account(){

  # Create a steam role account if it doesn't exist
  id -u "${CONF_STEAM_USER}" >/dev/null 2>&1 || {
    sudo useradd -m "${CONF_STEAM_USER}" || {
      err "Failed to create ${CONF_STEAM_USER}"
      exit ${E_ROLE_ADD_FAILED}
    }
  }

  # Add current user to CONF_STEAM_USER group
  sudo usermod -a -G "${CONF_STEAM_USER}" "${USER}" || {
    err "Failed to add ${USER} to group: ${CONF_STEAM_USER}"
    exit ${E_USER_GROUP_ADD_FAILED}
  }
}

#######################################
# Creates path using sudo
# Globals:
#  None
# Arguments:
#   directory_path
# Returns:
#   None
#######################################
create_path() {
  local directory_path="${1}"
  if ! sudo mkdir -p "${directory_path}" ; then
    err "Failed to create ${directory_path}"
    exit ${E_FAILED_TO_CREATE_PATH}
  fi
}

#######################################
# Recursively sets ownership
# Globals:
#  None
# Arguments:
#   directory_path
#   owner
#   group
# Returns:
#   None
#######################################
set_ownership() {
  local directory_path="${1}"
  local owner="${2}"
  local group="${3}"
  
  if ! sudo chown -Rv "${owner}":"${group}" "${directory_path} ; then
    err "Failed to set ownership for ${owner}:${group}"
    exit ${E_FAILED_TO_SET_PERMISSIONS}
  fi
}

#######################################
# Creates paths for steam and application
# Globals:
#  CONF_STEAM_PATH
#  CONF_STEAM_USER
#  CONF_GAME_PATH
#  CONF_GAME_PATH_APPLICATION
#  CONF_GAME_PATH_SCRIPTS
#  CONF_GAME_PATH_CONFIGS
#  CONF_GAME_PATH_LIB
#  CONF_GAME_PATH_LOGS
#  CONF_GAME_PATH_SAVES
#  CONF_GAME_PATH_BACKUPS
# Arguments:
#   None
# Returns:
#   None
#######################################
create_steam_paths(){

  # create steam and app folders
  create_path "${CONF_STEAM_PATH}"
  create_path "${CONF_GAME_PATH}"
  create_path "${CONF_GAME_PATH_APPLICATION}"
  create_path "${CONF_GAME_PATH_SCRIPTS}"
  create_path "${CONF_GAME_PATH_CONFIGS}"
  create_path "${CONF_GAME_PATH_LIB}"

  create_path "${CONF_GAME_PATH_LOGS}"
  create_path "${CONF_GAME_PATH_SAVES}"
  create_path "${CONF_GAME_PATH_BACKUPS}"

  set_ownership "${CONF_STEAM_PATH}" "${CONF_STEAM_USER}" "${CONF_STEAM_USER}"
  set_ownership "${CONF_GAME_PATH}" "${CONF_STEAM_USER}" "${CONF_STEAM_USER}"

}


#######################################
# Copies the management scripts to the correct locations.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
copy_management_scripts() {
  #sudo cp 
}



#######################################
# Installs everything
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
do_install(){
  show_warning
  create_role_account
  create_steam_paths
  copy_management_scripts


}


#######################################
# Main
#######################################
main(){
  do_install
}
