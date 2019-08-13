#!/bin/sh

set -u
set -e
set -x

if [ $# -ne 1 -a $# -ne 2 ]; then
	echo "usage $0 tftp_server_ip [flavour]"
	exit 1
fi

set +u
FLAVOUR_PREFIX=""
if [ -n "$2" ]; then
	FLAVOUR_PREFIX="${2}-"
fi
set -u

KERNEL_FILENAME="${FLAVOUR_PREFIX}kernel.fit.img"
ROOTFS_FILENAME="${FLAVOUR_PREFIX}rootfs.squashfs"
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
