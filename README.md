# Heads up

Almost none of this has really been tested and it's not 
battle hardened or idiot proof. It's very likely it won't
build first time. If it doesn't don't get mad. Open an
issue instead. 

Like everything created by random people messing around 
in their spare time this works for me by your mileage 
may vary.

# Getting Started

## Building

Assuming you're on a recent Debian or Debian-like system you
should only need to install these packages:

```
build-essential
file
wget
cpio
python
unzip
rsync
bc
git
```

For the first build you probably need to pull in the submodules.

```
make bootstrap
make
```

After that running ```make``` alone should be enough.

There is a target called ```buildindocker``` that should potentially
allow you to build on OSX or Windows but it hasn't really been tested.

## Getting access the u-boot prompt

The ch340e usb->uart bridge used for the serial console doesn't like the 
sudden change in baud rate when the board is booting and will inject some junk.

To stop that breaking auto boot instead of stopping auto boot and going to 
the u-boot prompt on any input u-boot is configured to wait for the string 
"bzzbzz" instead.

u-boot will give you 10 seconds to enter "bzzbzz" before auto booting.
This is should give you enough time to plug in the usb, have the serial
port register and repeatedly mash "bzzbzzbzz" on your keyboard.

## SSH Access

[br2autosshkey](https://github.com/fifteenhex/br2autosshkey) will create
an ssh key and grant access to sudo for a user called "bzzbzz". The public
and private keys for the user will be in ```buildroot/output/sshkeys/bzzbzz```.
You can use the private key to login via SSH by doing something like
```ssh -i buildroot/output/sshkeys/bzzbzz bzzbzz@<board ip>```.

Keep in mind this is only intended to be a little bit better than a hardcoded password.

## Configuration via beecfg

TODO

## Adding apps, your own code, doing useful stuff

The first thing you should do is to create your own fork of this repo.
Then create yourself a project branch for the project you're working on
so that you can update master at any time and not have merge conflicts.

### Adding your own apps to the firmware

A skeleton buildroot external directory is provided in ```br2apps``` for
you to add your packages into.

### App container

TBD

## Updating/recovery using the rescue image

TODO

# Boring technical details

You probably don't need to know this stuff...

## Overlays

### Overlay naming convention

- overlays : function_pingroup
- interfaces : interface_on_function/pin
- accessories: accessory_on_function/pin

### Loading the kernel without any overlays

The FIT has it's default configuration linked to the breadbee config
so just loading the FIT into memory and pointing ```bootm``` at it should
be enough. If needed you can specify the configuration after the load address.

```
sf probe; if sf read ${loadaddr} 0x80000 0x300000; then bootm ${loadaddr}#<boardtype>; fi
```

### Loading the kernel with overlays

u-boot allows loading multiple configurations defined in the FIT and applying
them in order. We use this to load the base configuration for the type of board
(currently breadbee or breadbee_crust) and load configurations with device tree
overlays to do the configuration.

```
sf probe; if sf read ${loadaddr} 0x80000 0x300000; then bootm ${loadaddr}#<boardtype>#<overlay1>#<overlay2>; fi
```

# Low-level u-boot fun

## Supplied u-boot environment variables

 * ```bb_boardtype``` - During board init we check the chip rev register and 
   set this to either ```breadbee``` if you have an MSC313e or ```breadbee_crust```
   if you have the older MSC313 (without an e).

## MAC addresses

If your kernel DT supplies aliases for ethernet0 through to ethernet3 u-boot will
insert MAC address based on the chip's unique ID so that they are fixed and you
don't need to go crazy trying to work out why you can't get an address from your
DHCP server anymore after rebooting 100 or times.

## Updating parts of the firmware

Run ```make run_tftpd``` to get a local tftp server. 
You will need permission to use sudo and may need to open port 69 on the host machine.
Use ```setenv serverip <ip address>``` to point at your tftp server.

### Replacing the kernel and rootfs via tftp:

```
if dhcp nor-16.img; then; sf probe; sf erase 0x80000 0xf80000; sf write 0x22080000 0x80000 0xf80000; fi
```

### Replacing just the kernel

```
if dhcp kernel.fit.img; then;sf probe;sf erase 0x80000 0x300000;sf write 0x22000000 0x80000 0x300000;fi

```

### Replacing just the rootfs

```
if dhcp nor-16.img; then; sf probe; sf erase 0x380000 0xc80000; sf write 0x22380000 0x380000 0xc80000; fi
```

### Replacing u-boot

```
if dhcp nor-16.img; then; sf probe; sf erase 0x20000 0x50000; sf write 0x22020000 0x20000 0x50000; fi
```

This will replace the SPL as well as u-boot meaning you won't be able to load u-boot via ymodem if it fails. Use with care

```
if dhcp nor-16.img; then; sf probe; sf erase 0x10000 0x60000; sf write 0x22010000 0x10000 0x60000; fi
```

### Replacing everything

Don't do this unless you have a way to reflash u-boot if it gets broken!

```
if dhcp nor-16.img; then; sf probe; sf erase 0x0 0x1000000; sf write 0x22000000 0x0 0x1000000; fi
```

### Booting the RAM only rescue image

#### from flash

sf probe; if sf read ${loadaddr} 0xd00000 0x300000; then bootm ${loadaddr}; fi

#### via tftp

```
if dhcp rescue.fit.img; then bootm; fi
```
