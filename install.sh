#!/bin/bash

## Projeto:     Acessibilidade na instalação do Arch Linux
## Autor:       Rodrigo Leutz

mkdir -p /mnt/espeakup-install
cd /mnt/espeakup-install

# Swap size info
echo "Enter the size of swapfile in MegaBytes"
read SWAPSIZE
echo "SWAP=$SWAPSIZE" > .config.var

# City
echo "Enter the name of thecity to localtime:"
read CITY
echo "CITY=$CITY" >> .config.var

# Charset encode
echo "Enter the chaset encode like pt_BR.UTF-8"
read CHARSETENC
echo "CHARSET=$CHARSETENC" >> .config.var

# KEYMAP
echo "Enter the keymap of your keyboard like br-abnt2"
read KEYMAP
echo "KEYMAP=$KEYMAP" >> .config.var

# Hostname
echo "Enter the hostname"
read HOSTNAMEINP
echo "HOSTNAME=$HOSTNAMEINP" >> .config.var

# Localdomain
echo "Enter the localdomain"
read LOCALDOMAIN
echo "LOCALDOMAIN=$LOCALDOMAIN" >> .config.var

# Username
echo "Enter the user name to use this computer"
read USERNAME
echo "USERNAME=$USERNAME" >> .config.var

# Make Swap
echo "Start make swap with $SWAPSIZE megabytes"
dd if=/dev/zero of=/mnt/swapfile bs=1M count=$SWAPSIZE
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# Install
espeak "Installing Arch Linux with pacstrap"
pacstrap /mnt espeak "Installing Arch Linux with pacstrap"
pacstrap /mnt base linux linux-firmware espeakup alsa-utils grub efibootmgr nano networkmanager links mplayer git mpg123 espeak-ng speech-dispatcher orca onboard gnome gnome-extra gnome-shell mate mate-extra sudo xorg-xinit
echo "Finish installation with pacstrap"
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/rodrigoleutz/arch-install/main/config.sh > config.sh
chmod +x config.sh
echo "Now going to arch-chroot"
arch-chroot /mnt ./espeakup-install/config.sh