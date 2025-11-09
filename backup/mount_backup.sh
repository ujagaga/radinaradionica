#!/usr/bin/env bash


LABEL="Backup"                # USB drive label
MOUNT_POINT="/mnt/usbbackup"


# Find device by label
DEV=$(blkid -L "$LABEL")
if [ -z "$DEV" ]; then
  echo "[$(date)] ERROR: USB with label '$LABEL' not found." 
  exit 1
fi

# Mount
mkdir -p "$MOUNT_POINT"
mount | grep -q "$MOUNT_POINT" || sudo mount "$DEV" "$MOUNT_POINT"
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to mount $DEV"
  exit 1
fi

cd "$MOUNT_POINT"
ls -la

