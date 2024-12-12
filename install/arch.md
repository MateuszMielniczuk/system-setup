# Arch Linux + snapshots + KDE Plasma test on VM

## 🔎 Description:

Instructions for installing and configuring a Linux system based on Arch Linux with snapshot functionality.
System uses required BTRFS partitions, Snapper for snapshots and KDE Plasma desktop. This setup is used for testing on a VM machine.
These instructions are based on arch wiki and [installation guide](https://wiki.archlinux.org/title/Installation_guide).
All was tested with `Qemu` virtual manager and `archlinux-2024.11.01` ISO.

## ✨ Features:

- Create and restore system snapshots using Snapper
- BTRFS system partition - required for system snapshots
- Create automatic snapshots before and after system and software updates with btrfs-xxxx
- Restore the system from the boot menu with grub-btrfs
- Desktop Environment - KDE Plasma

## 🛠️ Installation setup:

### SSH connection (optional)

If the device and VM are connected to the same Internet, which is usually the case with Virtual Manager installed on the local computer, it is easy to connect via SSH and use the local computer's terminal to install Arch. This is a more convenient option. It is easier to change the font size, scroll through the terminal window to see older commands and output.

First install ssh on the VM Arch installation, enable the ssh service and set the ISO root password for security.

```sh
pacman -Sy --needed openssh;
systemctl enable sshd;
passwd
```

Check your IP address

```sh
ip address
```

Now connect via ssh on your local machine

```sh
ssh root@<your_ip_address>
```

### Setting up the keyboard layout

Use the grep command to find your keyboard layout

```sh
localectl list-keymaps | grep <your_language_code>
```

Apply keyboard settings

```sh
loadkeys <language_code>
```

### Connect to the Internet

This should work in the VM just like connecting an Ethernet cable to your computer.

Check that you are connected to the Internet.

```sh
ip a
```

To connect to WiFi:

```sh
iwctl
```

And use steps: `device list` -> `station <device> scan` -> `station <device> get-networks` -> `station <device> connect <Network_name>` -> `exit`.

If you are using Ethernet or the VM, make sure your device is listed.

```sh
ip link
```

### Update the system clock

Clock should be synced automatically, to check the status of the system clock

```sh
timedatectl
```

## 💾 Partitioning

You can check what type of boot mode is in your system:

```sh
cat /sys/firmware/efi/fw_platform_size
```

If the file exists you are on UEFI, if not you are on BIOS.

### Creating and formatting partitions

The easiest way to partition the hard disk is to use `cfdisk`. On the VM the BIOS is used and there won't be any instructions on how to create a UEFI partition in this guide. Create two partitions, one for BIOS, 100MB is more than enough, and the rest for the Linux filesystem.

```sh
cfdisk /dev/<disk>
```

Format the Linux partition as BTRFS and add a larger node size for metadata (default 16k max 64k). Higher node sizes give better packing and less fragmentation at the cost of more expensive memory operations while updating the metadata blocks.

```sh
mkfs.btrfs -f -L <your_label> -n 32k /dev/<linux_partition>
```

### Creating subvolumes

The only way to add new subvolumes is to go into recovery mode and repeat the following steps as root. It is necessary to remount partition to the `/mnt` like below. Another option is to use the live ISO.

Mount the Linux partition:

```sh
mount /dev/<linux_patrition> /mnt
```

Create BTRFS subvolumes, the `su cr` command is an abbreviation of `su`bvolume `cr`eate. The following subvolumes are required for snapper and the system to work properly, and to reduce snapshot slowdowns (pacman, tmp)

```sh
btrfs su cr /mnt/@;
btrfs su cr /mnt/@home;
btrfs su cr /mnt/@snapshots;
btrfs su cr /mnt/@log;
btrfs su cr /mnt/@swap;
btrfs su cr /mnt/@pacman;
btrfs su cr /mnt/@tmp
```

Now unmount `/mnt` and remount the Linux partition with below settings

```sh
umount /mnt;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@ /dev/vda2 /mnt
```

More about selected options can be found here: [link](https://btrfs.readthedocs.io/en/latest/ch-mount-options.html)
| Option | desc |
| ------ | ------ |
| noatime | Significantly improves performance because no new access time information needs to be written. Default option here is `relatime`, but it is not working well with BTRFS! Read more in [here](https://lwn.net/Articles/499293/) |
| compress | Control BTRFS file data compression. Type may be specified as zlib, lzo, zstd or no. More in here: [link](https://btrfs.readthedocs.io/en/latest/Compression.html) |
| space_cache | The free space cache greatly improves performance when reading block group free space into memory. V2 is newer better version. But it is good to make sure to have it is set. |
| subvol | Subvolume path |

Create folders for home, snopshots, swap and other subvolumes

```sh
mkdir -p /mnt/{home,var/log,var/tmp,var/cache/pacman/pkg,.snapshots,swap}
```

and mount subvolumes

```sh
mount -o noatime,compress=lzo,space_cache=v2,subvol=@home /dev/vda2 /mnt/home;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@log /dev/vda2 /mnt/var/log;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@tmp /dev/vda2 /mnt/var/tmp;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@pacman /dev/vda2 /mnt/var/cache/pacman/pkg;
mount -o noatime,compress=lzo,space_cache=v2,subvol=@snapshots /dev/vda2 /mnt/.snapshots
```

## 💿 System installation

### Setting up mirrors for faster downloads

This can speed up our download time and help prevent timeouts. Select the HTTPS mirrors that have been synchronized within the last 12 hours and are located in either Country1 or Country2, sort them by download speed, and overwrite the /etc/pacman.d/mirrorlist file with the results

```sh
reflector --country Country1,Country2 --protocol https --age 12 --sort rate --save /etc/pacman.d/mirrorlist
```

### Install base system and libraries

```sh
pacstrap -K /mnt base base-devel btrfs-progs git grub grub-btrfs inotify-tools linux linux-firmware linux-headers linux-lts linux-lts-headers man neovim networkmanager openssh reflector snapper sudo
```

### Generate fstab file

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

## ⌨️ Chroot

```sh
arch-chroot /mnt
```

### Set the date and time

To find your time zone

```sh
timedatectl list-timezones | grep <country>
```

```sh
ln -sf /usr/share/zoneinfo/<Region/City> /etc/localtime
```

Set the hardware clock

```sh
hwclock --systohc
```

### Set locale

Uncomment your locale in `/etc/locale.gen` and save the changes.
Generate the locale and add a new line with your locale to `/etc/locale.conf`

```sh
locale-gen;
echo LANG=<locale> > /etc/locale.conf
```

Set up your keymap

```sh
echo "KEYMAP=<keymap>" > /etc/vconsole.conf
```

### Set hostname and hosts

```sh
my_hostname=<hostname>;
echo $my_hostname >> /etc/hostname;
echo "127.0.0.1   localhost"$'\n'"127.0.1.1   $my_hostname.localdomain $my_hostname"$'\n'"::1         localhost" >> /etc/hosts
```

### Set root password and create user

```sh
my_username=<username>
passwd;
useradd -m -g users -G wheel $my_username
passwd $my_username
```

Use the following command and uncomment the line `%wheel ALL=(ALL) ALL` line to enable `sudo`

```sh
EDITOR=nvim visudo
```

### Enable network manager

```sh
systemctl enable NetworkManager
```

### Installing and configuring the grub boot loader

Here give the path to your disk volume not the partition where you want to install grub

```sh
grub-install /dev/<disk>;
grub-mkconfig -o /boot/grub/grub.cfg
exit
```

Unmount `/mnt` and reboot the system

```sh
umount -R /mnt
reboot
```

## ⚙️ Post Installation steps

Log in to the system with credentials provided in installation steps. 
If need to connect to the WiFi you can use: `nmtui`

### Install Desktop environment

Install KDE Plasma and kscreen for screen management

```sh
sudo pacman -S plasma-desktop kscreen
```

```sh
sudo pacman -S intel-ucode pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
```

```sh
sudo pacman -S firefox kitty zsh zsh-completions zsh-autosuggestions
```

### Install graphic card drivers for intel dedicated graphics

```sh
sudo pacman -S xf86-video-intel
```

### Install SDDM

Display managers are useful when you have multiple DE or WMs and want to choose where to boot from in a GUI fashion, also they take care of the launch process.

```sh
sudo pacman -S sddm
```

Enable SDDM service to make it start on boot

```sh
sudo systemctl enable sddm
```

# If using KDE I suggest installing this to control the SDDM configuration from the KDE settings App

sudo pacman -S --needed sddm-kcm

## Configure snapper

More information at point `5.3.1` on https://wiki.archlinux.org/title/Snapper

List your btrfs subvolumes with command

```sh
sudo btrfs sub list /
```

```sh
sudo unmount /.snapshots;
sudo rm -r /.snapshots;
sudo snapper -c root create-config /
```

Above command creates another subvolume /.snapshots that we do not need. Delete this subvolume, create subvolume folder if not exists and mount subvolume:

```sh
sudo btrfs sub del /.snapshots/
sudo mkdir /.snapshots
sudo mount -o subvol=@snapshots /dev/<disk> /.snapshots
```

Verify if snapshots subvolume is now in `/etc/fstab`. Mount all subvolumes and give 750 permissions to `.snapshots` folder

```sh
sudo mount -a
sudo chmod 750 /.snapshots
```

### Snapper configuration

Configuration files for Snapper are in `/etc/snapper/configs/root` file

nvim /etc/snapper/configs/root

Apply below changes

```sh
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

More info about Snapper configuration and grub-btrfs https://github.com/Antynea/grub-btrfs

To manually generate grub snapshot entries you can run:

```sh
sudo /etc/grub.d/41_snapshots-btrfs;
update grub;
grub-mkconfig -o /boot/grub/grub.cfg
```

### Fix restore ro snapshots from grub

Instructions for Arch: https://github.com/Antynea/grub-btrfs/blob/master/initramfs/readme.md

```sh
git clone https://github.com/Antynea/grub-btrfs.git
sudo cp grub-btrfs/initramfs/overlay_snap_ro-install /etc/initcpio/install/grub-btrfs-overlayfs
sudo cp grub-btrfs/initramfs/overlay_snap_ro-hook /etc/initcpis/hooks/grub-btrfs-overlayfs
rm -rd grub-btrfs
```

Edit /etc/mkinitcpio.conf file and add `grub-btrfs-overlayfs` at the end of the line HOOKS=(... grub-btrfs-overlayfs)

```sh
nvim /etc/mkinitcpio.conf
```

Regenerate mkinitcpio

```sh
sudo mkinitcpio -P
```

### Automatically create snapshots on Pacman crud

# https://github.com/wesbarnett/snap-pac

```sh
sudo pacman -S snap-pac
```

## Create and enable swapfile

```sh
$swap_size=xxx;
btrfs filesystem mkswapfile --size '$swap_size'g --uuid clear /swap/swapfile;
swapon swap/swapfile
```

Edit fstab and add swapfile entry

```sh
vim /etc/fstab
```

`/swap/swapfile none swap defaults 0 0`
