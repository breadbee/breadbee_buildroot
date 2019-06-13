# Getting access the u-boot prompt

The ch340e usb->uart bridge doesn't like the sudden change in baud rate
when the board is booting and will inject some junk. To stop that breaking
auto boot instead of stopping auto boot and going to the u-boot prompt
on any input u-boot is configured to wait for the string "bzzbzz" instead.

# Loading the kernel without any overlays

```
sf probe; if sf read ${loadaddr} 0x80000 0x300000; then bootm ${loadaddr}; fi
```

# Loading the kernel with overlays

```
sf probe; if sf read ${loadaddr} 0x80000 0x300000; then bootm ${loadaddr}#base#overlay1#overlay2; fi
```

Note that the naming convention for the overlays is <function>_<pingroup> for pin mux configuration.
So spi0 on the spi0 pin group is spi0_spi0. For devices on a bus the from is <device>_on_<bus>. For
example spidev_on_spi.

# Updating parts of the firmware

Run ```make run_tftp``` to get a local tftp server.
Use ```setenv serverip <ip address>``` to point at your tftp server.

## Replacing the kernel and rootfs via tftp:

```
if dhcp nor-16.img.breadbee; then; sf probe; sf erase 0x80000 0xf80000; sf write 0x22080000 0x80000 0xf80000; fi
```

## Replacing just the kernel

```
if dhcp kernel.fit.img; then;sf probe;sf erase 0x80000 0x300000;sf write 0x22000000 0x80000 0x300000;fi
```

## Replacing u-boot

```
if dhcp nor-16.img.breadbee; then; sf probe; sf erase 0x20000 0x50000; sf write 0x22020000 0x20000 0x50000; fi
```

This will replace the SPL as well as u-boot meaning you won't be able to load u-boot via ymodem if it fails. Use with care

```
if dhcp nor-16.img.breadbee; then; sf probe; sf erase 0x10000 0x60000; sf write 0x22010000 0x10000 0x60000; fi
```

## Replacing everything

Don't do this unless you have a way to reflash u-boot if it gets broken!

```
if dhcp nor-16.img.breadbee; then; sf probe; sf erase 0x0 0x1000000; sf write 0x22000000 0x0 0x1000000; fi
```
