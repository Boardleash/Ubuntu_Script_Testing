#!/bin/bash
# Author: Boardleash (Derek)
# Date: Sunday, July 7 2024

# This is a script intended to be ran after a fresh install of Ubuntu LTS 24.04 Desktop.
# In this version of the script, VIM, CURL, Docker and LibreOffice are installed because they are what I use pretty often.
# A use-case for this is if a drive fails, a partition corrupts or a general fresh install is needed.

# NOTE: The "fresh.log" serves as the log for capturing all steps and errors.  This is stored in /tmp/ directory, so will be removed on reboot.
# If desired to keep the log, you can change the directory (and log name if desired) as necessary.

# ALSO NOTE: If you are having issues running this script, check permissions (chmod) and run with root privileges (sudo).

# Provide amplifying information in the restoration log, only visible in the log.
echo > /tmp/fresh.log
echo "This is the restoration process for Ubuntu LTS 24.04 Desktop." >> /tmp/fresh.log
echo "In this process, a fresh install will occur for VIM, CURL, Docker and LibreOffice." >> /tmp/fresh.log
echo "Additionally, a system update will be performed." >> /tmp/fresh.log
echo "Docker and SSH services will also be verified." >> /tmp/fresh.log

# Set up variables for formatting.
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'
bold=$(tput bold)
normal=$(tput sgr0)

# Set up a spinner for indication of the processes running to the user.
spinner() {
	local i sp n
	sp='/-\|'
	n=${#sp}
	printf ' '
	while sleep 0.1; do
		printf "%s\b" "${sp:i++%n:1}"
	done
}

# Announce to user that the minimal recovery process has started and a reboot will occur at the end.
echo | tee -a /tmp/fresh.log
echo "$bold The minimal recovery process is starting.  There will be a reboot at the end!" | tee -a /tmp/fresh.log

###########################
### VIM PACKAGE INSTALL ###
###########################

# Announce to user that VIM is going to be installed.
echo "VIM is going to be installed now, if it doesn't already exist." | tee -a /tmp/fresh.log
echo | tee -a /tmp/fresh.log

# Start VIM install.
spinner &
apt install -y vim &>> /tmp/fresh.log
echo | tee -a /tmp/fresh.log

kill "$!"
printf "\b"

# Announce to user that VIM install is complete.
echo "VIM has been successfully installed!" | tee -a /tmp/fresh.log

############################
### CURL PACKAGE INSTALL ###
############################

# Announce to user that CURL is going to be installed.
echo "CURL is going to be installed now, if it doesn't already exist."

# Start CURL install.
spinner &
apt install -y curl &>> /tmp/fresh.log

kill "$!"
printf "\b"

# Announce to user that CURL install is complete.
echo "CURL has been successfully installed!" | tee -a /tmp/fresh.log

##################################
### DOCKER REMOVAL and INSTALL ###
##################################

# Announce to user that the Docker removal process is starting and initiate Docker uninstall. 
echo "Removing old versions of Docker, if they even existed." | tee -a /tmp/fresh.log
echo >> /tmp/fresh.log
spinner &
apt remove -y docker.io &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt remove -y docker-doc &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt remove -y docker-compose &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt remove -y docker-compose-v2 &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt remove -y podman-docker &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt remove -y containerd &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt remove -y runc &>> /tmp/fresh.log
echo >> /tmp/fresh.log

kill "$!"
printf "\b"

# Announce to user that Docker removal has completed.
echo "Old versions of Docker have been removed, if they ever existed." | tee -a /tmp/fresh.log
echo >> /tmp/fresh.log

# Add Docker's official GPG key to host.
echo "Starting fresh install of Docker." | tee -a /tmp/fresh.log
spinner &
apt install ca-certifications curl &>> /tmp/fresh.log
install -m 0755 -d /etc/apt/keyrings &>> /tmp/fresh.log
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc &>> /tmp/fresh.log
chmod a+r /etc/apt/keyrings/docker.asc &>> /tmp/fresh.log
echo >> /tmp/fresh.log

# Add Docker's apt repo to the apt sources.
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update &>> /tmp/fresh.log

# Install latest version of Docker.
echo >> /tmp/fresh.log
apt install -y docker-ce &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt install -y docker-ce-cli &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt install -y containerd.io &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt install -y docker-buildx-plugin &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt install -y docker-compose-plugin &>> /tmp/fresh.log
echo >> /tmp/fresh.log

# Configure user and group associations for docker.
useradd -c "Docker User" -s /bin/bash dockman &>> /tmp/fresh.log
usermod -aG docker dockman &>> /tmp/fresh.log
echo >> /tmp/fresh.log

kill "$!"
printf "\b"

# Annouce to user that Docker has been successfully installed.
echo "Docker has been successfully installed!"
echo >> /tmp/fresh.log

#######################################
### LIBREOFFICE REMOVAL and INSTALL ###
#######################################

# Announce to user that LibreOffice is going to be removed and installed.
echo "LibreOffice will be removed, if it ever existed.  A fresh install of LibreOffice will begin after the removal." | tee -a /tmp/fresh.log
echo >> /tmp/fresh.log

# Start LibreOffice removal.
spinner &
apt purge libreoffice? libobasis? &>> /tmp/fresh.log
echo >> /tmp/fresh.log

# Start LibreOffice install.
apt install libreoffice-common
echo >> /tmp/fresh.log
wget https://download.documentfoundation.org/libreoffice/stable/24.2.4/deb/x86_64/LibreOffice_24.2.4_Linux_x86-64_deb.tar.gz &>> /tmp/fresh.log
echo >> /tmp/fresh.log
tar xvf LibreOffice_24.2.4_Linux_x86-64_deb.tar.gz &>> /tmp/fresh.log
echo >> /tmp/fresh.log
cd LibreOffice_24.2.4.2_Linux_x86-64_deb/DEBS/ &>> /tmp/fresh.log
apt install -y *.deb &>> /tmp/fresh.log
echo >> /tmp/fresh.log
rm -rf /home/*/Libre* &>> /tmp/fresh
echo >> /tmp/fresh

kill "$!"
printf "\b"

# Announce to user that LibreOffice has been successfully installed.
echo "LibreOffice has been successfully installed!" | tee -a /tmp/fresh.log
echo >> /tmp/fresh.log

############################
### GNOME TWEAKS INSTALL ###
############################
# NOTE: This package may not really be necessary for Debian/Ubuntu.  OMIT if necessary.

# Announce to user that GNOME-TWEAKS is being installed.
#echo "GNOME-TWEAKS will now be installed." | tee -a /tmp/fresh.log
#echo >> /tmp/fresh.log

# Start the GNOME-TWEAKS installation.
#spinner &
#apt install -y gnome-tweaks &>> /tmp/fresh.log
#echo >> /tmp/fresh.log
#
#kill "$!"
#printf "\b"

# Announce to user that GNOME-TWEAKS install is complete.
#echo "GNOME-TWEAKS has been successfully installed!" | tee -a /tmp/fresh.log
#echo >> /tmp/fresh.log

#########################################
### UPDATE SYSTEM and VERIFY SERVICES ### 
#########################################

# Announce to user that system is being updated.
echo "Updates are being applied to the system now." | tee -a /tmp/fresh.log
echo >> /tmp/fresh.log

# Run the command to update the system.
spinner &
apt update -y &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt upgrade -y &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt autoclean -y &>> /tmp/fresh.log
echo >> /tmp/fresh.log
apt autoremove -y &>> /tmp/fresh.log
echo >> /tmp/fresh.log

kill "$!"
printf "\b"

# Announce to user that updates are complete and that services are being verified.
echo | tee -a /tmp/fresh.log
echo "System updated, now, services will be verified." | tee -a /tmp/fresh.log
echo | tee -a /tmp/fresh.log

# Verify Docker services.
var_docker=$(systemctl is-active docker)
var_docker_enabled=$(systemctl is-enabled docker)
if [ $var_docker == 'active' ]; then
	echo -e "Docker is:$green $var_docker $reset" | tee -a /tmp/fresh.log
else
	echo -e "$bold Docker is:$red $var_docker $reset" | tee -a /tmp/fresh.log
fi
if [ $var_docker_enabled == 'enabled' ]; then
	echo -e "$bold Docker is:$green $var_docker_enabled $reset" | tee -a /tmp/fresh.log 
else 
	echo -e "$bold Docker is:$red $var_docker_enabled $reset" | tee -a /tmp/fresh.log
fi
echo | tee -a /tmp/fresh.log

# Verify SSH services.
var_sshd_enabled=$(systemctl is-enabled sshd)
var_sshd=$(systemctl is-active sshd)
if [ $var_sshd == 'active' ]; then
	echo -e "$bold SSH is:$green $var_sshd $reset" | tee -a /tmp/fresh.log
else
	echo -e "$bold SSH is:$red $var_sshd $reset" | tee -a /tmp/fresh.log
fi
if [ $var_sshd_enabled == 'enabled' ]; then
	echo -e "$bold SSH is:$green $var_sshd_enabled $reset" | tee -a /tmp/fresh.log
else
	echo -e "$bold SSH is:$red $var_sshd_enabled $reset" | tee -a /tmp/fresh.log
fi
echo | tee -a /tmp/fresh.log

# Announce to user that a reboot will occur in 10 seconds.
echo "$bold This system will reboot in 10 seconds. $normal" | tee -a /tmp/fresh.log
echo | tee -a /tmp/fresh.log

# Run command to reboot system, with 10 second delay.
spinner &
sleep 10s &>> /tmp/fresh.log;
reboot &>> /tmp/fresh.log
