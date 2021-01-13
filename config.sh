#!/bin/bash

## Projeto:     Acessibilidade na instalação do Arch Linux
## Autor:       Rodrigo Leutz

get_var() {
	RESP=`cat /espeakup-install/.config.var | grep $1 | awk -F"=" '{ print $2 }'`
	echo $RESP
}

# localtime
CITY=`get_var CITY`
cd /usr/share/zoneinfo
CITYPATH=`find $(pwd) -name $CITY | head -n 1`
ln -sf $CITYPATH /etc/localtime
hwclock --systohc

# Charset
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
CHARSETENC=`get_var CHARSET`
ENC=`echo $CHARSETENC | awk -F'.' '{ print $2 }'`
echo "$CHARSETENC $ENC" >> /etc/locale.gen
locale-gen
echo "LANG=$CHARSETENC" > /etc/locale.conf

# Keymap
KEYMAP=`get_var KEYMAP`
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Hostname and localdomain
HOSTNAMEINP=`get_var HOSTNAME`
LOCALDOMAIN=`get_var LOCALDOMAIN`
echo $HOSTNAMEINP > /etc/hostname
echo "127.0.0.1 localhost.localdomain   localhost" >> /etc/hosts
echo "::1               localhost.localdomain   localhost" >> /etc/hosts
echo "127.0.1.1         $HOSTNAMEINP.$LOCALDOMAIN $HOSTNAMEINP" >> /etc/hosts

# PASSWD
ROOTPASSWD=`get_var ROOTPASSWD`
USERNAME=`get_var USERNAME`
USERPASSWD=`get_var USERPASSWD`
echo -e "$ROOTPASSWD\n$ROOTPASSWD" | passwd
useradd -m $USERNAME
echo -e "$USERPASSWD\n$USERPASSWD" | passwd $USERNAME
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
gpasswd -a $USERNAME wheel

# Finish install
# mkinitcpio -P
BOOT=`get_var BOOT`
if [[ "$BOOT" == "no" ]]; then
	DEVICE=`get_var DEVICE`
	grub-install $DEVICE
else
	grub-install --target=x86_64-efi --bootloader-id=grub_uefi
fi
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager

echo "exec startplasma-x11" >> /home/$USERNAME/.xinitrc

# ufw
ufw enable
systemctl enable ufw

rm -rf /espeakup-install
