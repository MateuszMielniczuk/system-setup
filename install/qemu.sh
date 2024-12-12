#!/bin/bash
# This script is used to start qemu with the given image file

sudo apt-get update
sudo apt install qemu-system -y
sudo apt install libvirt-daemon-system libvirt-clients
# sudo add user $USER libvirt
virsh list --all # To list all the VMs check if the VM is running

sudo apt install virt-manager -y
