#!/bin/bash


##############################################
# This script is for the old laptop/computer #
##############################################

# Check for Root 
user=$(whoami)
if [[ "$user" != "root" ]];
then
	echo "Error: Must be run as root or run with SUDO"
	exit
fi


# Check for Arch 
if (! uname -r | grep -q 'arch')
then
    exit
fi 

# Change ulimit for session
ulimit -n 524000 

# Create Packages File
pacman -Qqe > /tmp/packages.txt


function confirm() {
    if (whiptail --title "$1" --yesno "$2" 8 78); then
            $3
      else
            $4
      fi
}


# Enter username
pickCurrentUser() {
    clear
    read -p "Enter username of both machines: " currentUser
    confirm "Username" "Is $currentUser correct?" newIPAddress pickCurrentUser
}


# Get current IP address
newIPAddress(){
    clear
    read -p "Your New Machines IPV4? : " ipAddress
    confirm "IP Address" "Is $ipAddress correct?" start newIPAddress
}

start(){
    confirm "Starting Default Copy" "Confirm to copy $currentUser profile to $ipAddress" default exit
    clear
}

 
##############################################
#                  Copying!                  #
##############################################


# SCP ZSH, BASHRC, VIMRC to Default user
home(){
    scp "/home/$currentUser/.zshrc" "/home/$currentUser/.bashrc" "/home/$currentUser/.vimrc" $currentUser@$ipAddress:"/home/$currentUser/Desktop/Testing/RCs/"
}


# SCP ZSH theme 
zshTheme(){
    scp "/home/$currentUser/.oh-my-zsh/themes/fino.zsh-theme" $currentUser@$ipAddress:"/home/$currentUser/Desktop/Testing/ZSHTheme/"
}


# SCP Remmina
remmina(){
    scp -r /home/$currentUser/.local/share/remmina/* $currentUser@$ipAddress:"/home/$currentUser/Desktop/Testing/Remmina/"
}


# SCP .config
# TODO:


# Create Pacman Packages List and SCP
pacman(){
    scp '/tmp/packages.txt' $currentUser@$ipAddress:"/home/$currentUser/Desktop/Testing/Pacman/"
}


##############################################
#                Copying!(ROOT)              #
##############################################


# SCP Mint Icons 
icons(){
    scp -r "/usr/share/icons/" root@$ipAddress:"/usr/share/icons/" 
}


# SCP Mint themes
themes(){
    scp -r "/usr/share/themes/" root@$ipAddress:"/usr/share/themes/" 
}


# SCP lightdm config
lightdm(){
    scp "/etc/lightdm/lightdm.conf" $root@$ipAddress:"/etc/lightdm/"
}


# SCP Root ZSH Config 
zshThemeRoot(){
    scp "/root/.oh-my-zsh/themes/custom.zsh-theme" $root@$ipAddress:"/root/.oh-my-zsh/themes/"
}


default(){
    clear
    
    home
    clear && echo "ZSHRC, VIMRC, BASHRC transferred" && sleep 0.5 

    zshTheme
    clear && echo "Oh My Zsh theme transferred" && sleep 0.5

    remmina
    clear && echo "Remmina profiles transferred" && sleep 0.5

    pacman
    clear && echo "Packages list created & transferred" && sleep 0.5

}

pickCurrentUser