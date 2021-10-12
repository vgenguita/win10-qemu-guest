#!/bin/sh
ISODIR=/route/to/ISODIR/
#IMGDIR if you use disk file
IMGIDR=/home/victor/dev/qemu/DISKS/
#DEVICEDISK if you use real host hard disk
#Get your id with ls -lah /dev/disk/by-id/
DEVICEDISK=/dev/disk/by-id/ata-HARDDISK-EXAMPLE
#Windows 10 ISO
WINISO=${ISODIR}en_windows_10_consumer_editions_version_20h2_updated_nov_2020_x64_dvd_7727be28.iso
#Virtio ISO. Get it from https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.208-1/
VIRTIOISO=${ISODIR}virtio-win.iso
#qemu' s guest samba shared
SMBSHARED=/route/to/shared/FOLDER
##PCI device IDs.
GPUVIDEOID=04:00.0
GPUAUDIOID=04:00.1
##OVMF UEFI. The route may change depending of your GNU/Linux distro
OVMF=file=/usr/share/ovmf/x64/
## General Settings
OPTS=""
OPTS="$OPTS -serial none -parallel none"
OPTS="$OPTS -nodefaults"
OPTS="$OPTS -name windows"
OPTS="$OPTS -rtc clock=host,base=localtime"

## Machine settings in order to get HDMI Audio device properly working
OPTS="$OPTS -machine pc-q35-6.1"

# UEFI Settings
OPTS="$OPTS -drive if=pflash,format=raw,readonly=on,file=${OVMF}OVMF_CODE.fd"
OPTS="$OPTS -drive if=pflash,format=raw,readonly=on,file=${OVMF}OVMF_VARS.fd"

## CPU settings.
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp cores=4,threads=1"
# Enable KVM full virtualization support.
OPTS="$OPTS -enable-kvm"

## Memory settings
OPTS="$OPTS -m 12G"
# Assign memory to the VM. Hugepages requires additional configuration.
#OPTS="$OPTS -mem-path /dev/hugepages"
#OPTS="$OPTS -mem-prealloc"

## VFIO GPU and GPU sound passthrough.
#Details and extra steps:
#https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
OPTS="$OPTS -device vfio-pci,host=${GPUVIDEOID},multifunction=on"
OPTS="$OPTS -device vfio-pci,host=${GPUAUDIOID}"


## Hard Disk Settings
# NOTE: Giving the VM *raw* disk access can lead to unintended things
OPTS="$OPTS -device virtio-scsi-pci,id=scsi"
OPTS="$OPTS -drive file=${DEVICEDISK},cache=none,if=virtio,format=raw"

## DVD Settings. Enable during instalation and initial setup
# Load our OS setup image e.g. ISO file.
OPTS="$OPTS -cdrom ${WINISO}"
# load virtio drivers
OPTS="$OPTS -drive file=${VIRTIOISO},index=3,media=cdrom"


##GPU Settings
#VIRTIO Device. Enable during instalation and initial setup, comment latter
OPTS="$OPTS -vga virtio"
OPTS="$OPTS -display sdl,gl=on"

#NONE. Enable in order to use only PCI_passthrough device.
#After initial setup and drivers installed, comment VIRTIO settings
#OPTS="$OPTS -vga none"
# running from the shell
#OPTS="$OPTS -nographic"

##USB Settings
OPTS="$OPTS -device qemu-xhci"
# Otherwise, use the other XHCI controller (USB 1.1, 2, 3) if you're
# running qemu < 2.10:
# https://en.wikibooks.org/wiki/QEMU/Devices/USB/Root
#OPTS="$OPTS -device nec-usb-xhci,id=xhci"
# Or if you need USB 2.0 support only
#OPTS="$OPTS -device usb-ehci,id=ehci"
OPTS="$OPTS -usb"
# Passthrough USB devices. Use lsusb to get ID vendor:productid values
#Example device.
#OPTS="$OPTS -device usb-host,vendorid=0x0c45,productid=0x6366"

## Network configuration
#In order to redirect ports
PORTREDIRECT=""
# RDP from 3389 on guest to 5555 on host
PORTREDIRECT=$PORTREDIRECT"hostfwd=tcp::5555-:3389,"
# Another one example
#PORTREDIRECT="$PORTREDIRECT\hostfwd=tcp::XXXX-:YYYY,"
#OPTS="$OPTS -net nic -net user"
#8080 Oracle HTTP Listener
#2030 Oracle Services for Microsoft Transaction Server
#1521 ORacle Database Listener
OPTS="$OPTS -net nic -net user,${PORTREDIRECT}smb=${SMBSHARED}"

##Launc VM
qemu-system-x86_64 $OPTS
