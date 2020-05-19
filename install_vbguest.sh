#!/bin/bash

# Install VBGuest additions on Ubuntu server. First script after fresh install.
# Script by Juan Miguel Expósito.
# V1.0

# To copy these files from local to the intended server using SSH use:
# scp * user@server:~


## To Do / Possible improvements:
# 1) Ask the user to confirm default variables in case they didn't change the script?
# 2) Use flag for defaults?
# 3) Consider in the future automating running the second script, probably by appending
#    the script execution to bashrc, and restoring the original as its first action.
# 4) I could integrate both stages in a single script and use maybe a temp file to signal
#    if it's the first or second stage. 
# 5) See about improving error handling.




############## SETUP ALL THE VARIABLES!!!
VBSHARE=/vboxshare   # VirtualBox shared folder mount point, as defined in the VM

### Initial update & install misc tools
# use figlet to display banners that are easy to find visually so the process less confusing.
sudo apt-get install -y figlet > /dev/null # install figlet silently

if [ $? -ne 0 ]; then
    echo "Package manager has errored, aborting"
    exit 1
fi


figlet "Updating   repos..."
sleep 1
sudo apt-get update
figlet "Updating   packages..."
sleep 1
sudo apt-get upgrade -y

### Install Vbox Guest Additions to enable shared folder

figlet "Adding   dependencies..."
sleep 2
sudo apt-get install -y build-essential
figlet "Please insert VBGuest media now"
read -n 1 -s -r -p "Press any key when ready"
echo
echo "Mounting drive"
sudo mount /dev/cdrom /media
sudo mkdir $VBSHARE
sudo chmod 777 $VBSHARE
sleep 1
sudo /media/VBoxLinuxAdditions.run
sudo usermod -a -G vboxsf $USER
figlet "Rebooting..."
sleep 2
# Actually logging out and back in would be enough, but not really easy to do.
# Could fail if the script is executed, so you'd need to run "source script"
# But there would be no way to provide an error message or instructions.
# Also, can't enforce a logout if running on terminal in a graphical environment
sudo reboot

