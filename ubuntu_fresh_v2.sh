#!/bin/bash
#
# TITLE: ubuntu_fresh_v2.sh
# AUTHOR: Boardleash (Derek)
# DATE: Thursday, July 11 2024
#
# A script created to perform a fresh/clean install of VIM, CURL,Docker and LibreOffice.
# Performs system updates and verification of Docker service as well.
# Tested on Ubuntu Desktop LTS 24.04 VM image.
# Ensure correct permissions have been set (chmod) if having issues running this script.
# This script should be ran with elevated privileges (sudo).

# Provide brief description of script, only visible in the "fresh.log" file.
{
	echo "This script will perform a clean install of VIM, CURL, Docker and LibreOffice."
	echo "System updates will be performed, as well as verification of Docker service."
	echo "A reboot will occur at the end of script execution." 
} > /var/fresh.log > /var/fresh_errors.log

# Establish formatting variables.
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

# Create spinner function to show an "in progress" status to user.
spinner() {
	local i sp n
	sp='/-\|'
	n=${#sp}
	printf ' '
	while sleep 0.1; do
		printf "%s\b" "${sp:i++%n:1}"
	done
}

# Notify user that script is being executed.
echo; echo "Script execution has begun.  There will be a reboot!" | tee -a /var/fresh.log

###########################
### VIM PACKAGE INSTALL ###
###########################

# Notify user VIM is being installed. 
echo "Starting VIM install." | tee -a /var/fresh.log
spinner &
spinner_pid=$!
apt install -y vim >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user VIM install is complete.
echo "VIM install complete." | tee -a /var/fresh.log

############################
### CURL PACKAGE INSTALL ###
############################

# Notify user CURL is being installed.
echo "Starting CURL install." | tee -a /var/fresh.log
apt install -y curl >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user CURL install is complete.
echo "CURL install complete." | tee -a /var/fresh.log

##################################
### DOCKER REMOVAL and INSTALL ###
##################################

# Notify user Docker will be removed. 
echo "Removing Docker, if it exists." | tee -a /var/fresh.log
{
	apt purge --auto-remove -y docker*
	apt purge --auto-remove -y podman-docker
	apt purge --auto-remove -y containerd*
	apt purge --auto-remove -y runc
} >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user Docker removal is complete.
echo "Docker has been removed, if it existed." | tee -a /var/fresh.log

# Notify user Docker install is starting. 
echo "Starting Docker install." | tee -a /var/fresh.log

# Get Docker's GPG key.
{
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc
} >> /var/fresh.log 2>> /var/fresh_errors.log

# Add Docker's apt repo to the apt sources.
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	tee /etc/apt/sources.list.d/docker.list >> /var/fresh.log 2>> /var/fresh_errors.log

# Start Docker install.
apt install -y docker* >> /var/fresh.log 2>> /var/fresh_errors.log

# Create a Docker user and associate with Docker group.
# If this is not desired, remove or comment out this part.
# If a different user is preferred, change "dockman" to preferred user.
{
	useradd -c "Docker User" -s /bin/bash dockman
	usermod -aG docker dockman 
} >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user Docker install is complete.
echo "Docker install complete." | tee -a /var/fresh.log

#######################################
### LIBREOFFICE REMOVAL and INSTALL ###
#######################################

# Notify user LibreOffice will be removed.
echo "Uninstalling LibreOffice, if it exists." | tee -a /var/fresh.log

# Start LibreOffice removal.
{
	apt purge --auto-remove -y libreoffice*
	apt purge --auto-remove -y libobasis* 
} >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user LibreOffice install is starting.
echo "Installing LibreOffice." | tee -a /var/fresh.log

# Start LibreOffice install.
{
	apt install -y libreoffice-common
	wget https://download.documentfoundation.org/libreoffice/stable/24.2.4/deb/x86_64/LibreOffice_24.2.4_Linux_x86-64_deb.tar.gz
	tar xvf LibreOffice_24.2.4_Linux_x86-64_deb.tar.gz
	cd LibreOffice_24.2.4.2_Linux_x86-64_deb/DEBS/ || exit
	apt install -y ./*deb* 
	rm -rf /home/*/Libre*
} >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user LibreOffice has been installed. 
echo "LibreOffice install complete." | tee -a /var/fresh.log

############################
### GNOME-TWEAKS INSTALL ###
############################
# This package may not really be necessary for Debian/Ubuntu.
# Commenting out this portion of code due to this.  If it is needed, uncomment as necessary.

# Notify user GNOME-Tweaks install is starting.
#echo "Installing GNOME-Tweaks." | tee -a /var/fresh.log

# Start the GNOME-TWEAKS installation.
#apt install -y gnome-tweaks >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user GNOME-Tweaks has been installed.
#echo "GNOME-Tweaks install complete." | tee -a /var/fresh.log

#########################################
### UPDATE SYSTEM and VERIFY SERVICES ### 
#########################################

# Notify user that system updates are being performed..
echo "Starting system updates." | tee -a /var/fresh.log

# Start system updates.
{
	apt update -y
	apt upgrade -y
	apt autoclean -y
	apt autoremove -y 
} >> /var/fresh.log 2>> /var/fresh_errors.log

# Notify user that system updates are complete and services are being verified.
echo "System updates complete.  Verifying Docker service." | tee -a /var/fresh.log

# Verify Docker service.
var_docker=$(systemctl is-active docker)
var_docker_enabled=$(systemctl is-enabled docker)
if [ "$var_docker" == 'active' ]; then
	echo -e "Docker is:$green $var_docker $reset" | tee -a /var/fresh.log
else
	echo -e "Docker is:$red $var_docker $reset" | tee -a /var/fresh.log
fi
if [ "$var_docker_enabled" == 'enabled' ]; then
	echo -e "Docker is:$green $var_docker_enabled $reset" | tee -a /var/fresh.log 
else 
	echo -e "Docker is:$red $var_docker_enabled $reset" | tee -a /var/fresh.log
fi

# Notify user that reboot will occur in 10 seconds.
echo "This system will reboot in 10 seconds." | tee -a /var/fresh.log

# Start 10 second delay followed by reboot.
{
	sleep 10s
	kill -9 $spinner_pid
	reboot 
} >> /var/fresh.log 2>> /var/fresh_errors.log

# EOF
