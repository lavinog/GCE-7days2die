#! /bin/bash
# Installs 7 days to die server on a linux server and configures management scripts
# Source can be found at https://github.com/lavinog/GCE-7days2die
#
# Following Google's bash style guide:
# https://google.github.io/styleguide/shell.xml

readonly E_CANCELLED=1
readonly E_ROLE_ADD_FAILED=2
readonly E_USER_GROUP_ADD_FAILED=3


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



}


#######################################
# Main
#######################################
main(){
  do_install
}
