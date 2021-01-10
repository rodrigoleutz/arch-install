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
echo "Wait enter key to type passwd"
read
echo "Type root password twice"
passwd
echo "Password for root work"
USERNAME=`get_var USERNAME`
useradd -m $USERNAME
echo "Type $USERNAME password twice"
passwd $USERNAME
echo "Password for $USERNAME work"
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Finish install
# mkinitcpio -P
echo "Install grub"
BOOT=`get_var BOOT`
if [[ "$BOOT" == 1 ]]; then
	DEVICE=`get_var DEVICE`
	grub-install $DEVICE
else
	grub-install --target=x86_64-efi --bootloader-id=grub_uefi
fi
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager

# Enable espeakup
systemctl enable espeakup
alsactl store

# Orca
cd /espeakup-install
mkdir orca-install
cd orca-install
git clone https://github.com/felipefacundes/brasiltts
cd brasiltts
cp *tts-generic.conf /etc/speech-dispatcher/modules/
cp speechd.conf /etc/speech-dispatcher/
echo "orca &" >> /home/$USERNAME/.xinitrc
echo "exec mate-session" >> /home/$USERNAME/.xinitrc
echo "sudo systemctl stop espeakup" >> /home/$USERNAME/.bashrc
echo "startx" >> /home/$USERNAME/.bashrc

# ufw
ufw enable
systemctl enable ufw

rm -rf /espeakup-install
echo "Now type reboot to reboot the system"
