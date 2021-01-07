#!/bin/bash

## Projeto:     Acessibilidade na instalação do Arch Linux
## Autor:       Rodrigo Leutz

mkdir -p /mnt/espeakup-install
cd /mnt/espeakup-install

# Swap size info
systemctl stop espeakup
espeak "Enter the size of swapfile in MegaBytes"
systemctl start espeakup
read SWAPSIZE
systemctl stop espeakup
echo "SWAP=$SWAPSIZE" > .config.var

# City
espeak "Enter the name of thecity to localtime:"
systemctl start espeakup
read CITY
systemctl stop espeakup
echo "CITY=$CITY" >> .config.var

# Charset encode
espeak "Enter the chaset encode like pt_BR.UTF-8"
systemctl start espeakup
read CHARSETENC
systemctl stop espeakup
echo "CHARSET=$CHARSETENC" >> .config.var

# KEYMAP
espeak "Enter the keymap of your keyboard like br-abnt2"
systemctl start espeakup
read KEYMAP
systemctl stop speakup
echo "KEYMAP=$KEYMAP" >> .config.var

# Hostname
espeak "Enter the hostname"
systemctl start espeakup
read HOSTNAMEINP
systemctl stop speakup
echo "HOSTNAME=$HOSTNAMEINP" >> .config.var

# Localdomain
espeak "Enter the localdomain"
systemctl start espeakup
read LOCALDOMAIN
systemctl stop espeakup
echo "DOMAIN=$LOCALDOMAIN" >> .config.var

# Username
espeak "Enter the user name to use this computer"
systemctl start espeakup
read USERNAME
systemctl stop espeakup
echo "USERNAME=$USERNAME" >> .config.var

# Make Swap
espeak "Start make swap with $SWAPSIZE megabytes"
dd if=/dev/zero of=/mnt/swapfile bs=1M count=$SWAPSIZE
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# Install
espeak "Installing Arch Linux with pacstrap"
pacstrap /mnt espeak "Installing Arch Linux with pacstrap"
pacstrap /mnt base linux linux-firmware espeakup alsa-utils grub efibootmgr nano networkmanager links mplayer git mpg123 espeak-ng speech-dispatcher orca onboard mate mate-extra sudo xorg-xinit
espeak "Finish installation with pacstrap"
espeak "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/rodrigoleutz/arch-install/main/config.sh > config.sh
chmod +x config.sh
espeak "Now going to arch-chroot"
arch-chroot /mnt ./config.sh
