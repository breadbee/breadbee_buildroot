#!/bin/sh

set -u
set -e

if [ $# -ne 1 ]; then
	echo "usage $0 tftp_server_ip"
	exit 1
fi

RESCUE_FILENAME="rescue.fit.img"
TMPDIR="/tmp/flasher"
TFTPSERVER=$1

mkdir -p $TMPDIR

echo "Fetching rescue image..."

tftp -r $RESCUE_FILENAME -l $TMPDIR/$RESCUE_FILENAME -g $TFTPSERVER

echo "Writing rescue images..."

flashcp -v $TMPDIR/$RESCUE_FILENAME /dev/mtd4

echo "Done."
