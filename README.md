# Loading the kernel without any overlays

sf probe; sf read ${loadaddr} 0x80000 0x300000; bootm ${loadaddr}

# Loading the kernel with overlays

sf probe; sf read ${loadaddr} 0x80000 0x300000; bootm ${loadaddr}#base#overlay1#overlay2

#Replacing the kernel and rootfs via tftp:

setenv serverip 192.168.3.1; dhcp nor-16.img.breadbee; sf probe; sf erase 0x80000 0xf80000; sf write 0x22080000 0x80000 0xf80000
