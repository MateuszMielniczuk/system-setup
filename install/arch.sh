#===================================================
# START INSTRUCTIONS
#===================================================

pacman -Sy --needed openssh
systemctl enable sshd
passwd
ip address

# Connect to ssh on your machine `root@ip`

ssh root@<ip_address>

#===================================================
# INSTRUCTIONS
#===================================================

loadkeys pl;
timedatectl

cfdisk /dev/vda
# here create two partitions one for BIOS small 100M and rest linux filesystem 

mkfs.btrfs -f -n 32k /dev/vda2;
mount /dev/vda2 /mnt

btrfs su cr /mnt/@;
btrfs su cr /mnt/@home;
btrfs su cr /mnt/@snapshots;
btrfs su cr /mnt/@log;
btrfs su cr /mnt/@swap;
btrfs su cr /mnt/@pacman;
btrfs su cr /mnt/@tmp

umount /mnt;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@ /dev/vda2 /mnt;
mkdir -p /mnt/{home,var/log,var/tmp,var/cache/pacman/pkg,.snapshots,swap};
mount -o noatime,compress=lzo,space_cache=v2,subvol=@home /dev/vda2 /mnt/home;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@log /dev/vda2 /mnt/var/log;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@tmp /dev/vda2 /mnt/var/tmp;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@pacman /dev/vda2 /mnt/var/cache/pacman/pkg;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@snapshots /dev/vda2 /mnt/.snapshots

reflector --country Poland,Iceland --protocol https --age 12 --sort rate --save /etc/pacman.d/mirrorlist;
pacstrap -K /mnt base base-devel btrfs-progs git grub grub-btrfs inotify-tools linux linux-firmware linux-headers linux-lts linux-lts-headers man neovim networkmanager openssh reflector snapper sudo

genfstab -U /mnt >> /mnt/etc/fstab;
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Atlantic/Reykjavik /etc/localtime;
hwclock --systohc;
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen;
locale-gen;
echo LANG=en_US.UTF-8 >> /etc/locale.conf;
echo KEYMAP=pl >> /etc/vconsole.conf

my_hostname=<hostname>
echo $my_hostname > /etc/hostname
echo "127.0.0.1   localhost"$'\n'"127.0.1.1   $my_hostname.localdomain $my_hostname"$'\n'"::1         localhost" >> /etc/hosts

my_username=<username>;
passwd;
useradd -m -g users -G wheel $my_username;
passwd $my_username

EDITOR=nvim visudo
#
# Uncomment line with wheel %wheel ALL=(ALL) ALL
#
swap_size=8;
btrfs filesystem mkswapfile --size "$swap_size"g --uuid clear /swap/swapfile;
swapon /swap/swapfile

# Edit fstab and add swap entry
echo '/swap/swapfile    none    swap     defaults   0   0' >> /etc/fstab

systemctl enable NetworkManager;
systemctl enable sshd;
grub-install /dev/vda;
grub-mkconfig -o /boot/grub/grub.cfg;
exit

umount -R /mnt;
reboot

#===================================================
# END INSTRUCTIONS
#===================================================

# POST INSTALLATOIN
# INFO if need to connect to the wifi you can use: `nmtui`

# INFO Install KDE Plasma and kscreen for screen management
# INFO Install graphic card drivers for intel dedicated graphics
sudo pacman -S plasma-desktop kscreen;
sudo pacman -S firefox kitty;
sudo pacman -S xf86-video-intel

#Display managers are useful when you have multiple DE or WMs and want to choose where to boot from in a GUI fashion, also they take care of the launch process.

# Install SDDM
sudo pacman -S sddm;
sudo systemctl enable sddm;
sudo pacman -S --needed sddm-kcm

# INFO configure snapper
# https://wiki.archlinux.org/title/Snapper point 5.3.1

sudo umount /.snapshots;
sudo rm -r /.snapshots
sudo snapper -c root create-config /
# this is creating another subvolume /.snapshots we do not need
sudo btrfs sub del /.snapshots/
sudo mkdir /.snapshots
sudo mount -o subvol=@snapshots /dev/vda2 /.snapshots
# check if this in in /etc/fstab
sudo mount -a

sudo chmod 750 /.snapshots

# INFO snapper configuration is inside /etc/snapper/configs/root

sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# INFO configure snapper and grub-btrfs https://github.com/Antynea/grub-btrfs 
# To manually generate grub snapshot entries you can run:
# sudo /etc/grub.d/41_snapshots-btrfs
# update grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# INFO Fix restore ro snapshots from grub
# Instructions for Arch: https://github.com/Antynea/grub-btrfs/blob/master/initramfs/readme.md

git clone https://github.com/Antynea/grub-btrfs.git;
sudo cp grub-btrfs/initramfs/Arch\ Linux/overlay_snap_ro-install /etc/initcpio/install/grub-btrfs-overlayfs;
sudo cp grub-btrfs/initramfs/Arch\ Linux/overlay_snap_ro-hook /etc/initcpio/hooks/grub-btrfs-overlayfs;
rm -rdf grub-btrfs

# edit /etc/mkinitcpio.conf file and add `grub-btrfs-overlayfs` at the end of the line HOOKS=(... grub-btrfs-overlayfs)
sudo nvim /etc/mkinitcpio.conf

# regenerate mkinitcpio
sudo mkinitcpio -P

# INFO automatically create snapshots on pacman crud 
# https://github.com/wesbarnett/snap-pac
sudo pacman -S snap-pac


# TODO Enable hibernation



# Follow the installation steps for Arch Linux website:
# https://wiki.archlinux.org/title/Installation_guide
# setfont -d - double font size
# INFO set keyboard layout polish
# `localectl list-keymaps | grep pl` - check available keymaps
# `loadkeys pl` 
# INFO verify your boot mode
# `cat /sys/firmware/efi/fw_platform_size` - if the file exists,
#   you are using UEFI, if not, you are using BIOS
# INFO connect to the internet
# `ip a` - check if you are connected
# if usisng wifi: `iwctl` -> `device list` -> `station <device> scan` -> `station <device> get-networks` -> `station <device> connect <Network_name>` -> exit
# if ethernet: `ip link`, and ensure your device is listed
# INFO update the system clock
# `timedatectl` - check the status of the system clock, it should be synced automatically
# INFO partition the disks
# `lsblk` - list all block devices
# `fdisk -l` - list all block devices with more details
# `gdisk </disk/name>` - create a new partition table (GPT) for UEFI
# `fdisk </disk/name>` - create a new partition table (MBR) for BIOS
# CREATE BOOT PARTITION:
# `n` - for new partition -> default number -> default first sector -> +512M -> `ef00` for EFI System or ef02 for BIOS boot partition (VM)
# 'n' - for btrfs partition -> default number -> default first sector -> default last sector (to allocate space till the end) -> default linux filesystem 8300
# `w` - write changes to disk -> `y` - confirm
# INFO format the partitions
# WARNING if you have system partition, do not format it, you can destroy bootloaders
# `mkfs.fat -F32 </boot/partition>` - format boot partition for UEFI -> ext4 for BIOS `mkfs.ext4 </boot/partition>`
# `mkfs.btrfs -L <my_label> -n 32k </btrfs/partition>` - format btrfs partition, add larger 32KB nodesize for metadata (default is 16, max 64)
# INFO mount the file systems
# `mount /dev/<btrfs_partition> /mnt` - mount btrfs partition
# INFO create subvolumes
# TODO consider creating subvolume for pkg /var/cache/pacman/pkg
# `btrfs subvolume create /mnt/@` - create subvolume for root
# `btrfs su cr /mnt/@swap` - create swap subvolume
# `btrfs su cr /mnt/@home` - create subvolume for home
# `btrfs su cr /mnt/@root` - create subvolume for root
# `btrfs su cr /mnt/@tmp` - create subvolume for tmp
# `btrfs su cr /mnt/@opt` - create subvolume for opt
# `btrfs su cr /mnt/@log` - create subvolume for /var/log
# `btrfs su cr /mnt/@containers` - create subvolume for /var/lib/containers
# `btrfs su cr /mnt/@images` - create subvolume for /var/lib/libvirt/images
# `btrfs su cr /mnt/@docker` - create subvolume for /var/lib/docker
# `btrfs su cr /mnt/@snapshots` - create subvolume for snapshots
#
# `umount /mnt` - unmount btrfs partition
# `mount -o noatime,compress=lzo,space_cache=v2,subvol=@ /dev/<btrfs_partition> /mnt` - mount btrfs partition with subvolume
#
# mkdir -p /mnt/{swap,home,root,tmp,opt,var/log,var/lib/containers,var/lib/libvirt/images,var/lib/docker,.snapshots}
#
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@swap /dev/<btrfs_partition> /mnt/swap
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@home /dev/<btrfs_partition> /mnt/home
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@root /dev/<btrfs_partition> /mnt/root
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@tmp /dev/<btrfs_partition> /mnt/tmp
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@opt /dev/<btrfs_partition> /mnt/opt
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@log /dev/<btrfs_partition> /mnt/var/log
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@containers /dev/<btrfs_partition> /mnt/var/lib/containers
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@images /dev/<btrfs_partition> /mnt/var/lib/libvirt/images
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@docker /dev/<btrfs_partition> /mnt/var/lib/docker
# mount -o noatime,compress=lzo,space_cache=v2,subvol=@snapshots /dev/<btrfs_partition> /mnt/.snapshots
#
# 
# INFO mount boot partition
#
# `mkdir /mnt/boot` - create boot directory
# `mount /dev/<boot_partition> /mnt/boot` - mount boot partition
#
# INFO Install essential packages
#
# `pacstrap -K /mnt linux linux-headers linux-firmware linux-lts linux-lts-headers base base-devel neovim` - install base system, linux kernel, linux firmware
#
# linux-firmware - possibly missing firmware for linuu
#
# INFO Configure the system
#
# `genfstab -U /mnt >> /mnt/etc/fstab` - generate fstab file
#
# `arch-chroot /mnt` - change root to the new system
#
# `timedatectl list-timezones | grep <country>` - find your timezone
# `ln -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime` - set timezone
#
# `hwclock --systohc` - set hardware clock
#
# edit /etc/locale.gen file and uncomment your locale
# `locale-gen` - generate locale
#
# `nvim /etc/locale.conf` - create locale file and add `LANG=<your_lang>.UTF-8` line eg en_US.UTF-8
# 
# `nvim /etc/vconsole.conf` - create vconsole file and add `KEYMAP=<keybord_map>` line eg `pl`
#
# `nvim /etc/hostname` - create hostname file and add your hostname (eg laptop-name)
#
# WARN check this step
# `nvim /etc/hosts` - create hosts file and add:
#
# 127.0.0.1   localhost
# 127.0.1.1   hostname.localdomain hostname
# ::1         localhost
#
# WARN end check
# 
# INFO Set root password and user
# `passwd` - set root password - if not done before (ssh step)
# `useradd -m -g users -G wheel <username>` - create user
# `passwd <username>` - set user password TODO do we need this?
# 
# INFO Install required packages
#
# `pacman -S grub networkmanager network-manager-applet git snapper cups hplip sudo openssh efibootmgr`
# `systemctl enable NetworkManager` - enable network manager
# `systemctl enable sshd` - enable ssh if not done before
#
# INFO edit /etc/mkinitcpio.conf
# add `MODULES=(btrfs)` to MODULES
# `mkinitcpio -p linux` - regenerate initramfs
#
# INFO Install Video Driver
# read about your video card and install appropriate driver
#
# INFO setup grub
#
# `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB` - install grub
# `grub-install --target=i386-pc /dev/XXX` - install grub for BIOS, where xxx is your disk not partition cg /dev/sda not /dev/sda1
#
# TODO install desktop environment
#
# probably you need to install it as user
#
#  
# INFO exit chroot
# `exit`
# INFO unmount all partitions
# `umount -R /mnt`
# INFO reboot
# `reboot`
#
#
# INFO Enable swap file
# `btrfs filesystem mkswapfile --size <size>g --uuid clear /mnt/swap/swapfile` - create swapfile
# `swapon mnt/swap/swapfile` - enable swapfile
#
# `vim /etc/fstab` - edit fstab file
#
# add line: /mnt/swap/swapfile none swap defaults 0 0
#
# INFO post installation
# `sudo systemctl enable NetworkManager` - enable network manager
# `sudo systemctl enable sshd` - enable ssh
# `sudo systemctl enable cups` - enable cups
# `sudo systemctl enable snapper-timeline.timer` - enable snapper timeline
# `sudo systemctl enable snapper-cleanup.timer` - enable snapper cleanup
# `sudo systemctl enable snapper-boot.timer` - enable snapper boot
#
#
