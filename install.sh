#! /bin/bash

# Steam account
ROLE_ACCT='steam'

# Steam App ID
APP_ID=294420

#Steam Path
STEAM_PATH='/opt/steam'

#Application Path
APP_PATH='/opt/steam/7d2d'

#-------DO NOT EDIT BELOW THIS LINE--------

err(){
  # Prints to stderr in red color
  echo -e "\033[0;31m${1}\033[0m" 1>&2
}

# Create a steam role account if it doesn't exist
id -u $ROLE_ACCT >/dev/null 2>&1 || {
  sudo useradd -m ${ROLE_ACCT} || {
    err "Failed to create ${ROLE_ACCT}"
    exit 1
  }
}

# Add current user to ROLE_ACCT group
sudo usermod -a -G ${ROLE_ACCT} ${USER} || {
  err "Failed to add ${USER} to group: ${ROLE_ACCT}"
  exit 1
}

# create steam and app folders
sudo mkdir -p ${STEAM_PATH} || {
  err "Failed to create ${STEAM_PATH}"
  exit 1
}

sudo mkdir -p ${APP_PATH} || {
  err "Failed to create ${APP_PATH}"
  exit 1
}


sudo chown -Rv steam:steam ${STEAM_PATH} ${APP_PATH} || {
  err "Failed to set ownership for ${ROLE_ACCT}"
  exit 1
}

# Install steamcmd
# Steps from https://developer.valvesoftware.com/wiki/SteamCMD#Manually

# install lib32gcc1
sudo apt update
sudo apt -y install lib32gcc1

cd ${STEAM_PATH}
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo -u ${ROLE_ACCT} tar zxvf -

sudo -u ${ROLE_ACCT} ${STEAM_PATH}/steamcmd.sh +login anonymous +force_install_dir ${APP_PATH} +app_update ${APP_ID} +quit
