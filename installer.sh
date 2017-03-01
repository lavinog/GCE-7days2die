#! /bin/bash
# Installs 7 days to die server on a linux server and configures management scripts
# Source can be found at https://github.com/lavinog/GCE-7days2die
#
# Following Google's bash style guide:
# https://google.github.io/styleguide/shell.xml

readonly STEAMCMD_DOWNLOAD="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
readonly APP_ID=294420

readonly CURRENT_CONF_FILE="./config/7daystodie.conf"
source "${CURRENT_CONF_FILE}"


# Error Codes
readonly E_CANCELLED=1
readonly E_ROLE_ADD_FAILED=2
readonly E_USER_GROUP_ADD_FAILED=3
readonly E_FAILED_TO_CREATE_PATH=4
readonly E_FAILED_TO_SET_PERMISSIONS=5





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
  echo  'This script will install a 7 days to die server with the following settings:'
  echo '-------------------------------------------'
  grep CONF "${CURRENT_CONF_FILE}"
  echo '-------------------------------------------'
  echo .
  echo 'Additionally, this script will be running commands as root to do the following:'
  echo " * Create ${CONF_STEAM_USER} user"
  echo " * Create ${CONF_STEAM_PATH} folder"
  echo " * Create ${CONF_GAME_PATH} folder"
  echo .
  info 'Do you wish to continue? (y/n)' 'y'
  read -t30 -n1 -r KEY
  echo .
  if [ "${KEY}" == "y" ]; then
      info 'Starting Install' 'g'
  else
      info 'Cancelling install' 'r'
      exit "${E_CANCELLED}"
  fi
}

#######################################
# Displays error message in red to stdout and stderr
# Globals:
#   None
# Arguments:
#   message
# Returns:
#   None
#######################################
err() {
  echo -e "\033[0;31m${1}\033[0m" 1>&2
}

#######################################
# Displays info message in to stdout with color options
# Globals:
#   None
# Arguments:
#   color r,g,y,b
# Returns:
#   None
#######################################
info() {
  local message="${1}"
  local color="${2}"
  case ${color} in
    'r')
      echo -e "\033[0;31m${message}\033[0m" ;;
    'g')
      echo -e "\033[0;32m${message}\033[0m" ;;
    'y')
      echo -e "\033[0;33m${message}\033[0m" ;;
    'b')
      echo -e "\033[0;34m${message}\033[0m" ;;
    *)
      echo "${message}" ;;
  esac
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
  if id -u "${CONF_STEAM_USER}" >/dev/null 2>&1 ; then
    info "${CONF_STEAM_USER} user already exists" 'g'
  else
    info "Creating ${CONF_STEAM_USER} user using sudo" 'y'
    if sudo useradd -m "${CONF_STEAM_USER}" ; then
      info "${CONF_STEAM_USER} user created" 'g'
    else
      err "Failed to create ${CONF_STEAM_USER}"
      exit "${E_ROLE_ADD_FAILED}"
    fi
  fi
  
  # Add current user to CONF_STEAM_USER group
  info "Adding ${USER} user to ${CONF_STEAM_USER} group using sudo" 'y'
  if ! sudo usermod -a -G "${CONF_STEAM_USER}" "${USER}" ; then
    err "Failed to add ${USER} to group: ${CONF_STEAM_USER}"
    exit "${E_USER_GROUP_ADD_FAILED}"
  fi
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
  info "Creating ${directory_path} using sudo" 'y'
  if ! sudo mkdir -p "${directory_path}" ; then
    err "Failed to create ${directory_path}"
    exit "${E_FAILED_TO_CREATE_PATH}"
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
  
  info "Changing ownership of ${directory_path} to ${owner}:${group} using sudo" 'y'
  if ! sudo chown -Rv "${owner}:${group}" "${directory_path}" ; then
    err "Failed to set ownership for ${owner}:${group}"
    exit "${E_FAILED_TO_SET_PERMISSIONS}"
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

  sudo cp -v ./bin/* "${CONF_GAME_PATH_SCRIPTS}"
  sudo cp -v ./lib/* "${CONF_GAME_PATH_LIB}"
  sudo cp -v ./config/* "${CONF_GAME_PATH_CONFIGS}"

  fix_permissions
}


#######################################
# Sets the permissions on various files
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
fix_permissions() {
  set_ownership "${CONF_GAME_PATH}" "${CONF_STEAM_USER}" "${CONF_STEAM_USER}"
  info 'Setting file permissions using sudo' 'y'
  sudo chmod -v 755 "${CONF_GAME_PATH_SCRIPTS}"/*
  sudo chmod -v 644 "${CONF_GAME_PATH_LIB}"/*
  sudo chmod -v 664 "${CONF_GAME_PATH_CONFIGS}"/*
}


#######################################
# Installs required libraries and prompts user
# if they want additional packages
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
install_dependencies(){
  if dpkg-query -W lib32gcc1 telnet >/dev/null ; then
    info "Required dependencies are met" "g"
  else
    info "The following packages are required and will be installed:" 'y'
    info " * lib32gcc1" 'b'
    info " * telnet" 'b'
    echo .
    info 'Do you wish to continue? (y/n)' 'y'
    read -t30 -n1 -r KEY
    echo .
    if [ "${KEY}" == "y" ]; then
      info 'Installing packages' 'g'
      sudo apt update
      sudo apt -y install lib32gcc1 telnet
    else
      info 'Cancelling install' 'r'
      exit "${E_CANCELLED}"
    fi
  fi
}


#######################################
# Installs steamcmd
# Globals:
#   CONF_STEAM_PATH
#   CONF_STEAM_USER
#   STEAMCMD_DOWNLOAD
# Arguments:
#   None
# Returns:
#   None
#######################################
install_steamcmd() {
  info "The steamcmd tool will be downloaded from:" 'y'
  info "    ${STEAMCMD_DOWNLOAD}" 'b'
  info "and extracted to ${CONF_STEAM_PATH}" 'y'
    info 'Do you wish to continue? (y/n)' 'y'
  read -t30 -n1 -r KEY
  echo .
  if [ "${KEY}" == "y" ]; then
      info 'Installing steamcmd' 'g'
      curl -sqL "${STEAMCMD_DOWNLOAD}" \
        | sudo -u "${CONF_STEAM_USER}" tar zxvf - -C "${CONF_STEAM_PATH}"
  else
      info 'Cancelling install' 'r'
      exit "${E_CANCELLED}"
  fi
  
}

#######################################
# Installs application using steamcmd
# Globals:
#   CONF_STEAM_USER
#   CONF_GAME_PATH
#   APP_ID
# Arguments:
#   None
# Returns:
#   None
#######################################
install_application() {
  info "The steamcmd tool will download and install the application" 'y'
  info 'Do you wish to continue? (y/n)' 'y'
  read -t30 -n1 -r KEY
  echo .
  if [ "${KEY}" == "y" ]; then
      info 'Installing application' 'g'
      sudo -u "${CONF_STEAM_USER}" "${CONF_STEAM_PATH}"/steamcmd.sh \
        +login anonymous +force_install_dir "${CONF_GAME_PATH_APPLICATION}" \
        +app_update "${APP_ID}" +quit
  else
      info 'Cancelling install' 'r'
      exit "${E_CANCELLED}"
  fi
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
  install_dependencies
  install_steamcmd
  install_application
}


#######################################
# Main
#######################################
main(){
  do_install
}
main
