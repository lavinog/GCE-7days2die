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
readonly E_FAILED_TO_CREATE_LINK=6
readonly E_FAILED_TO_CONFIGURE_SAVE=7




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
show_install_warning() {
  echo  'This script will install a 7 days to die server with the following settings:'
  echo '-------------------------------------------'
  grep CONF "${CURRENT_CONF_FILE}"
  echo '-------------------------------------------'
  echo
  echo 'Additionally, this script will be running commands as root to do the following:'
  echo " * Create ${CONF_STEAM_USER} user"
  echo " * Create ${CONF_STEAM_PATH} folder"
  echo " * Create ${CONF_GAME_PATH} folder"
  echo
  info 'Do you wish to continue? (y/n)' 'y'
  read -t30 -n1 -r KEY
  echo
  if [ "${KEY}" == "y" ]; then
      info 'Starting Install' 'g'
  else
      info 'Cancelling install' 'r'
      exit "${E_CANCELLED}"
  fi
}


#######################################
# Displays information about updating to the user and prompts to continue.
# Exits with E_CANCELLED if user presses anything but 'y'
# Globals:
#   CURRENT_CONF_FILE
# Arguments:
#   None
# Returns:
#   None
#######################################
show_update_warning() {
  echo  'This script will update the 7 days to die server with the following settings:'
  echo '-------------------------------------------'
  grep CONF "${CURRENT_CONF_FILE}"
  echo '-------------------------------------------'
  echo
  echo 'This script will be running commands as root to do the following:'
  echo " * Shutdown the ${CONF_GAME_SERVICE_NAME} service"
  echo " * Update the application files in ${CONF_GAME_PATH}"
  echo " * Start the ${CONF_GAME_SERVICE_NAME} service"
  echo
  info 'Do you wish to continue? (y/n)' 'y'
  read -t30 -n1 -r KEY
  echo
  if [ "${KEY}" == "y" ]; then
      info 'Starting Update' 'g'
  else
      info 'Cancelling Update' 'r'
      exit "${E_CANCELLED}"
  fi
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
# Creates a symbolic link for the script configs to /etc
# Globals:
#   CONF_GAME_PATH_CONFIGS
#   E_FAILED_TO_CREATE_LINK
# Arguments:
#   None
# Returns:
#   None
#######################################
link_script_config_file() {
  info "linking ${CONF_GAME_PATH_CONFIGS}/7daystodie.conf to /etc/7daystodie.conf" 'y'
  if ! sudo cp -sv --force "${CONF_GAME_PATH_CONFIGS}/7daystodie.conf" "/etc/7daystodie.conf" ; then
    err "Failed to create symbolic link to /etc/7daystodie.conf"
    exit "${E_FAILED_TO_CREATE_LINK}"
  fi
}

#######################################
# Sets the permissions on various files
# Globals:
#   CONF_STEAM_USER
#   CONF_GAME_PATH_SCRIPTS
#   CONF_GAME_PATH_LIB
#   CONF_GAME_PATH_CONFIGS
#   CONF_GAME_PATH_APPLICATION
# Arguments:
#   None
# Returns:
#   None
#######################################
fix_permissions() {
  set_ownership "${CONF_GAME_PATH}" "${CONF_STEAM_USER}" "${CONF_STEAM_USER}"
  info 'Setting file permissions using sudo' 'y'
  sudo -u "${CONF_STEAM_USER}" chmod -v 755 "${CONF_GAME_PATH_SCRIPTS}"/*
  sudo -u "${CONF_STEAM_USER}" chmod -v 644 "${CONF_GAME_PATH_LIB}"/*
  sudo -u "${CONF_STEAM_USER}" chmod -v 664 "${CONF_GAME_PATH_CONFIGS}"/*

  # Removes execution bit to all files in the application folder 
  # Steamcmd installs all files as executables
  sudo -u "${CONF_STEAM_USER}" find "${CONF_GAME_PATH_APPLICATION}" \
      -type f -exec chmod 644 {} \;
  # Set only the two binary files to be executable
  if [[ -f "${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86_64" ]] ; then
    sudo -u "${CONF_STEAM_USER}" chmod ug+x \
        "${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86" \
        "${CONF_GAME_PATH_APPLICATION}/7DaysToDieServer.x86_64"
  fi
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
    info " * netcat" 'b'
    echo
    info 'Do you wish to continue? (y/n)' 'y'
    read -t30 -n1 -r KEY
    echo
    if [ "${KEY}" == "y" ]; then
      info 'Installing packages' 'g'
      sudo apt update
      sudo apt -y install lib32gcc1 telnet netcat
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
  if [[ -f "${CONF_STEAM_PATH}/steamcmd.sh" ]] ; then
    info 'The steamcmd tool is already installed.' 'y'
 
  else
    info "The steamcmd tool will be downloaded from:" 'y'
    info "    ${STEAMCMD_DOWNLOAD}" 'b'
    info "and extracted to ${CONF_STEAM_PATH}" 'y'
      info 'Do you wish to continue? (y/n)' 'y'
    read -t30 -n1 -r KEY
    echo
    if [ "${KEY}" == "y" ]; then
        info 'Installing steamcmd' 'g'
        curl -sqL "${STEAMCMD_DOWNLOAD}" \
          | sudo -u "${CONF_STEAM_USER}" tar zxvf - -C "${CONF_STEAM_PATH}"
    else
        info 'Cancelling install' 'r'
        exit "${E_CANCELLED}"
    fi
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
  echo
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
# Adds serverconfig.xml to config folder and adds save path
# Globals:
#   CONF_GAME_FILE_SERVER_CONFIG
#   CONF_STEAM_USER
#   CONF_GAME_PATH_APPLICATION
#   CONF_GAME_PATH_SAVES
# Arguments:
#   None
# Returns:
#   None
#######################################
configure_server() {
# Test if config file exists, if not copy from application
  if [[ -f "${CONF_GAME_FILE_SERVER_CONFIG}" ]] ; then
    info "${CONF_GAME_FILE_SERVER_CONFIG} already exists." 'g'
  else
    info "Creating ${CONF_GAME_FILE_SERVER_CONFIG}." 'y'
    if ! sudo -u "${CONF_STEAM_USER}" \
        cp -v "${CONF_GAME_PATH_APPLICATION}/serverconfig.xml" \
        "${CONF_GAME_FILE_SERVER_CONFIG}" ; then
      
      err 'Could not copy serverconfig.xml'
      exit E_FAILED_TO_CONFIGURE_SAVE
    fi
  fi

  info "Setting save path on ${CONF_GAME_FILE_SERVER_CONFIG}" 'y'
  local find_str="<\!--property name=\"SaveGameFolder\"\s*value=\"absolute path\" /-->"
  local replace_str="<property name=\"SaveGameFolder\"      value=\"${CONF_GAME_PATH_SAVES}\" />"

  if ! sudo -u "${CONF_STEAM_USER}" \
    sed -i -e "s@${find_str}@${replace_str}@" \
      "${CONF_GAME_FILE_SERVER_CONFIG}" ; then
    err 'Could not set save location'
    exit E_FAILED_TO_CONFIGURE_SAVE
  else
    grep SaveGameFolder "${CONF_GAME_FILE_SERVER_CONFIG}"
  fi

}
#######################################
# Adds creates cron job to backup server
# Globals:
#   CONF_GAME_FILE_SERVER_CONFIG
#   CONF_STEAM_USER
#   CONF_GAME_PATH_SCRIPTS
# Arguments:
#   None
# Returns:
#   None
#######################################
configure_backups() {
  local fullcmd="${CONF_GAME_PATH_SCRIPTS}/backup_save_full.sh"
  local diffcmd="${CONF_GAME_PATH_SCRIPTS}/backup_save_diff.sh"
  echo
  info "Manual backups can be started as follows:" 'y'
  info 'Full backup:' 'b'
  info "  sudo -u ${CONF_STEAM_USER} ${fullcmd}" 'b'
  info 'Differential backup:' 'b'
  info "  sudo -u ${CONF_STEAM_USER} ${diffcmd}" 'b'
  echo
  info 'These backups can be configured to automatically run:' 'y'
  info '  Full backup daily' 'b'
  info '  Diff backup hourly' 'b'
  echo
  info "Do you want the game server to start on boot? (y/n)" 'y'
  read -t30 -n1 -r KEY
  echo
  if [ "${KEY}" == "y" ]; then        
    info 'Setting service to autostart' 'g'               
     { echo "0 0 * * * ${fullcmd}"; \
         echo "0 1-23 * * * ${diffcmd}"; } \
         | sudo -u "${CONF_STEAM_USER}" crontab -
  else                        
    info 'Not configuring auto backups' 'r'
  fi                      
}
#######################################
# Creates systemd service file
# Globals:
#   SYSTEMD_FILE
#   CONF_STEAM_USER
#   CONF_GAME_PATH_SCRIPTS
#   CONF_GAME_SERVICE_NAME
# Arguments:
#   None
# Returns:
#   None
#######################################
configure_systemd_service() {
  local readonly systemd_file="/etc/systemd/system/${CONF_GAME_SERVICE_NAME}.service"
  
  info "Creating ${systemd_file} using root" 'y'
  sudo touch "${systemd_file}"
  sudo chmod 664 "${systemd_file}"

  cat <<EOF | sudo tee ${systemd_file} >/dev/null
[Unit]
Description=7 Days to Die Server
After=network.target

[Service]
Type=idle
User=${CONF_STEAM_USER}
ExecStart=${CONF_GAME_PATH_SCRIPTS}/start_server.sh
ExecStop=${CONF_GAME_PATH_SCRIPTS}/stop_server.sh
KillSignal=SIGINT
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

  # Reload Systemd and enable autostart
  # use sudo systemctl disable service to disable autostart
  info 'Updating systemd service list using root' 'y'
  sudo systemctl daemon-reload
  echo
  info "In order for the game server to start on boot, the service must be" 'y'
  info "enabled.  This can be enabled using the following:" 'y'
  info "   sudo systemctl enable ${CONF_GAME_SERVICE_NAME}" 'b'
  echo
  info 'If not enabled, you will need to start the service manually using:' 'y'
  info "   sudo systemctl start ${CONF_GAME_SERVICE_NAME}" 'b'
  echo
  info "Do you want the game server to start on boot? (y/n)" 'y'
  read -t30 -n1 -r KEY
  echo
  if [ "${KEY}" == "y" ]; then
      info 'Setting service to autostart' 'g'
      sudo systemctl enable "${CONF_GAME_SERVICE_NAME}"
  else
      info 'Setting service to not autostart' 'r'
      sudo systemctl disable "${CONF_GAME_SERVICE_NAME}"
  fi  
}

#######################################
# Presents user with final documentation
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
finalize() {
  info 'Installation is complete' 'g'
  echo .
  info 'It is recommended that you edit the server config file using:' 'y'
  info "   nano ${CONF_GAME_FILE_SERVER_CONFIG}" 'b'
  echo
  info 'You can use the following commands to manage the server:' 'g'
  echo
  info 'To manually start the server:' 'g'
  info "   sudo systemctl start ${CONF_GAME_SERVICE_NAME}" 'b'
  echo
  info 'To manually stop the server:' 'g'
  info "   sudo systemctl start ${CONF_GAME_SERVICE_NAME}" 'b'
  echo
  info 'To disable auto start on boot:' 'g'
  info "   sudo systemctl disable ${CONF_GAME_SERVICE_NAME}" 'b'
  echo
  info 'To enable auto start on boot:' 'g'
  info "   sudo systemctl enable ${CONF_GAME_SERVICE_NAME}" 'b'
  echo
  info 'To console into the server:' 'g'
  info "   telnet localhost 8081" 'b'
  echo

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
  show_install_warning
  create_role_account
  create_steam_paths
  copy_management_scripts
  link_script_config_file
  install_dependencies
  install_steamcmd
  install_application
  configure_server
  configure_backups
  configure_systemd_service
  finalize
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
do_update(){
  show_update_warning
  sudo systemctl stop ${CONF_GAME_SERVICE_NAME}
  install_application
  sleep 2
  sudo systemctl start ${CONF_GAME_SERVICE_NAME}
}

