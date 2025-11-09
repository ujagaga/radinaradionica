#!/usr/bin/env bash


# Simple USB backup script

# === CONFIG ===
SRC="/home/rada/Applications"           # folder to back up
LABEL="Backup"                # USB drive label
MOUNT_POINT="/mnt/usbbackup"
LOG_FILE="/dev/shm/usb_backup.log"

# === SCRIPT ===
echo "[$(date)] Starting backup..." >> "$LOG_FILE"

# Find device by label
DEV=$(blkid -L "$LABEL")
if [ -z "$DEV" ]; then
  echo "[$(date)] ERROR: USB with label '$LABEL' not found." >> "$LOG_FILE"
  exit 1
fi

# Mount
mkdir -p "$MOUNT_POINT"
mount | grep -q "$MOUNT_POINT" || sudo mount "$DEV" "$MOUNT_POINT"
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to mount $DEV" >> "$LOG_FILE"
  exit 1
fi

# Perform backup (rsync for efficiency)
rsync -a --delete "$SRC/" "$MOUNT_POINT/backup/" >> "$LOG_FILE" 2>&1
RESULT=$?

# Sync and unmount
sync
sudo umount "$MOUNT_POINT"

if [ $RESULT -eq 0 ]; then
  echo "[$(date)] Backup successful." >> "$LOG_FILE"
else
  echo "[$(date)] Backup failed (rsync exit code $RESULT)." >> "$LOG_FILE"
fi
