#!/bin/bash

## Projeto:     Acessibilidade na instalação do Arch Linux
## Autor:       Rodrigo Leutz

# Função pra salvar config
save_config(){
	echo "$1=$2" >> /mnt/espeakup-install/.config.var
}

# Boot type
echo "Enter the boot type of your computer"
echo "1 = Bios legacy"
echo "2 = UEFI"
read BOOT
if [[ "$BOOT" == 1 ]]; then
	echo "Enter the device for boot"
	read DEVICE
	save_config DEVICE "/dev/$DEVICE"
fi
save_config BOOT $BOOT

# KEYMAP
echo "Enter the keymap of your keyboard like br-abnt2"
read KEYMAP
loadkeys $KEYMAP
mkdir -p /mnt/espeakup-install
cd /mnt/espeakup-install
save_config KEYMAP $KEYMAP

# Swap size info
echo "Enter the size of swapfile in MegaBytes"
read SWAPSIZE
save_config SWAP $SWAPSIZE

# City
echo "Enter the name of city to localtime:"
read CITY
save_config CITY $CITY

# Charset encode
echo "Enter the chaset encode like pt_BR.UTF-8"
read CHARSETENC
save_config CHARSET $CHARSETENC

# Hostname
echo "Enter the hostname"
read HOSTNAMEINP
save_config HOSTNAME $HOSTNAMEINP

# Localdomain
echo "Enter the localdomain"
read LOCALDOMAIN
save_config LOCALDOMAIN $LOCALDOMAIN

# Username
echo "Enter the user name to use this computer"
read USERNAME
save_config USERNAME $USERNAME

# Stop Time
echo "Now type ENTER to continue intallation OR CTRL+C to abort"
read

# Timedate
timedatectl set-ntp true

# Make Swap
echo "Start make swap with $SWAPSIZE megabytes"
dd if=/dev/zero of=/mnt/swapfile bs=1M count=$SWAPSIZE
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# Install
echo "Installing Arch Linux with pacstrap"
pacstrap /mnt base linux linux-firmware espeakup alsa-utils grub efibootmgr nano networkmanager links git espeak-ng speech-dispatcher orca onboard xorg xorg-server mate mate-extra sudo xorg-xinit ufw pulseaudio alsa-firmware alsa-plugins
systemctl stop espeakup
systemctl start espeakup
echo "Finish installation with pacstrap"
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/rodrigoleutz/arch-install/main/config.sh > config.sh
chmod +x config.sh
echo "Now going to arch-chroot"
arch-chroot /mnt ./espeakup-install/config.sh
