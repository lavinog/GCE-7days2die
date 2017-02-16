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


# Create a steam role account if it doesn't exist
id -u $ROLE_ACCT >/dev/null 2>&1
if [ $? -eq 1 ]
then
  sudo useradd -m ${ROLE_ACCT}
  if [ $? -ne 0 ]
  then
    echo "Failed to create ${ROLE_ACCT}"
    exit 1
  fi
fi

# create folders
sudo mkdir -p ${STEAM_PATH}
if [ $? -ne 0 ]
then
  echo "Failed to create ${STEAM_PATH}"
  exit 1
fi

sudo mkdir -p ${APP_PATH}
if [ $? -ne 0 ]
then
  echo "Failed to create ${APP_PATH}"
  exit 1
fi


sudo chown -Rv steam:steam ${STEAM_PATH} ${APP_PATH}
if [ $? -ne 0 ]
then
  echo "Failed to set ownership for ${ROLE_ACCT}"
  exit 1
fi


# Install steamcmd
# Steps from https://developer.valvesoftware.com/wiki/SteamCMD#Manually

# install lib32gcc1
sudo apt update
sudo apt -y install lib32gcc1

cd ${STEAM_PATH}
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo -u ${ROLE_ACCT} tar zxvf -

sudo -u ${ROLE_ACCT} ${STEAM_PATH}/steamcmd.sh +login anonymous +force_install_dir ${INSTALL_FOLDER} +app_update ${APP_ID} +quit
