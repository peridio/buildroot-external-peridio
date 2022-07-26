#!/bin/bash

# Use fwup to turn the Buildroot produced squashfs image into a fwup.conf respecting image.

set -e

filename="peridio-qemu-aarch64-virt"
fw_filename="$filename.fw"
image_filename="$filename.image"

# make .fw file
ROOTFS="$BINARIES_DIR/rootfs.squashfs" fwup \
  -c \
  -f $BR2_EXTERNAL_PERIDIO_PATH/board/qemu/aarch64-virt/fwup.conf \
  -o "$BINARIES_DIR/$fw_filename"

# make full image
fwup \
  -a \
  -d "$BINARIES_DIR/$image_filename" \
  -t complete \
  -i "$BINARIES_DIR/$fw_filename"

qemu-img resize -f raw "$BINARIES_DIR/$image_filename" 512M
