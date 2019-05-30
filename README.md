
sf probe; sf read ${loadaddr} 0x80000 0x300000; go ${loadaddr}

Replacing the kernel and rootfs:

dhcp nor-16.img.breadbee; sf probe; sf erase 0x80000 0xf80000; sf write 0x22080000 0x80000 0xf80000
