#!/bin/sh

set -u
set -e

KERNEL_FILENAME="kernel.fit.img"
ROOTFS_FILENAME="rootfs.squashfs"
TMPDIR="/tmp/flasher"
TFTPSERVER="192.168.3.235"

mkdir -p $TMPDIR

echo "Fetching firmware images..."

tftp -r $KERNEL_FILENAME -l $TMPDIR/$KERNEL_FILENAME -g $TFTPSERVER
tftp -r $ROOTFS_FILENAME -l $TMPDIR/$ROOTFS_FILENAME -g $TFTPSERVER

echo "Writing firmware images..."

flashcp -v $TMPDIR/$KERNEL_FILENAME /dev/mtd2
flashcp -v $TMPDIR/$ROOTFS_FILENAME /dev/mtd3

echo "Done."
