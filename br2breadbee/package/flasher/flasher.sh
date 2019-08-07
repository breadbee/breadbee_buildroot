#!/bin/sh

set -u
set -e

if [ $# -ne 1 ]; then
	echo "usage $0 tftp_server_ip"
	exit 1
fi

KERNEL_FILENAME="kernel.fit.img"
ROOTFS_FILENAME="rootfs.squashfs"
TMPDIR="/tmp/flasher"
TFTPSERVER=$1

mkdir -p $TMPDIR

echo "Fetching firmware images..."

tftp -r $KERNEL_FILENAME -l $TMPDIR/$KERNEL_FILENAME -g $TFTPSERVER
tftp -r $ROOTFS_FILENAME -l $TMPDIR/$ROOTFS_FILENAME -g $TFTPSERVER

echo "Writing firmware images..."

flashcp -v $TMPDIR/$KERNEL_FILENAME /dev/mtd2
flashcp -v $TMPDIR/$ROOTFS_FILENAME /dev/mtd3

echo "Done."
