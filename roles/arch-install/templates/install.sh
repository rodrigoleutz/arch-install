#!/bin/bash

## Projeto:     Acessibilidade na instalação do Arch Linux
## Autor:       Rodrigo Leutz

# Função pra salvar config
save_config(){
	echo "$1=$2" >> /mnt/espeakup-install/.config.var
}

if [[ "{{ uefi_boot }}" -eq "yes" ]]; then
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/{{ device }}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
  +100M # 100 MB boot parttion
  t # type
  ef # new partition
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  w # write the partition table
  q # and we're done
EOF
mkfs.vfat /dev/{{ device }}1
mkfs.ext4 /dev/{{ device }}2
mount /dev/{{ device }}2 /mnt
mkdir /mnt/boot/EFI
mount /dev/{{ device }}1 /mnt/boot/EFI
else
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/{{ device }}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  w # write the partition table
  q # and we're done
EOF
mkfs.ext4 /dev/{{ device }}1
mount /dev/{{ device }}1 /mnt
fi

# Create DIR
mkdir -p /mnt/espeakup-install

# Boot type
save_config DEVICE /dev/{{ device }}
save_config BOOT {{ uefi_boot }}

# KEYMAP
save_config KEYMAP {{ keymap }}

# Swap size info
save_config SWAP {{ swapsize }}

# City
save_config CITY {{ localtime }}

# Charset encode
save_config CHARSET {{ lang }}

# Hostname
save_config HOSTNAME {{ hostname }}

# Localdomain
save_config LOCALDOMAIN {{ localdomain }}

# Username
save_config USERNAME {{ new_user }}
save_config USERPASSWD {{ new_user_passwd }}

# Root passwd
save_config ROOTPASSWD {{ ansible_ssh_pass }}

# Timedate
timedatectl set-ntp true

# Make Swap
dd if=/dev/zero of=/mnt/swapfile bs=1M count={{ swapsize }}
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# Install
pacstrap /mnt base linux linux-firmware grub efibootmgr nano networkmanager openssh sudo ufw sddm {{ arch_packages }}
genfstab -U /mnt >> /mnt/etc/fstab

mv config.sh /mnt/espeakup-install
arch-chroot /mnt ./espeakup-install/config.sh
