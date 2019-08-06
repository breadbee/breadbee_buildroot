#!/bin/sh

set -u
set -e

RESCUE_FILENAME="rescue.fit.img"
TMPDIR="/tmp/flasher"
TFTPSERVER="192.168.3.235"

mkdir -p $TMPDIR

echo "Fetching rescue image..."

tftp -r $RESCUE_FILENAME -l $TMPDIR/$RESCUE_FILENAME -g $TFTPSERVER

echo "Writing rescue images..."

flashcp -v $TMPDIR/$RESCUE_FILENAME /dev/mtd4

echo "Done."
