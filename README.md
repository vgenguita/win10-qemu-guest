# win10-qemu-guest
Get a functional qemu windows 10 guest with real gpu of host
## Requirements
### Hardware
- A CPU with hardware virtualization support
- A motherboard with IOMMU support
- At least, one free graphic card to pass it to guest.
### PCI Passtrhough
1. Enable or check iommu on your host
2. Check IOMMU groups
```bash
#!/bin/bash
for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```	
3. Isolate GPU
Check this to get detailed steps -> [https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF) 

### Installing Windows 10
In **GPU Settings** of file.sh you must activate vitrio options
```bash

##GPU Settings
#VIRTIO Device. Enable during instalation and initial setup, comment latter
OPTS="$OPTS -vga virtio"
OPTS="$OPTS -display sdl,gl=on"

#NONE. Enable in order to use only PCI_passthrough device.
#After initial setup and drivers installed, comment VIRTIO settings
OPTS="$OPTS -vga none"
# running from the shell
OPTS="$OPTS -nographic"
```	
Check Installation of Windows 10 here ->  [https://www.funtoo.org/Windows_10_Virtualization_with_KVM](https://www.funtoo.org/Windows_10_Virtualization_with_KVM) 

Once windows is installed and configured, you would see video singal on monitor connected to guest' s GPU, now you can comment VIRTIO settings.

```bash
 
##GPU Settings
#VIRTIO Device. Enable during instalation and initial setup, comment latter
#OPTS="$OPTS -vga virtio"
#OPTS="$OPTS -display sdl,gl=on"

#NONE. Enable in order to use only PCI_passthrough device.
#After initial setup and drivers installed, comment VIRTIO settings
OPTS="$OPTS -vga none"
# running from the shell
OPTS="$OPTS -nographic"
```	
