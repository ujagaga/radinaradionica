#!/usr/bin/env bash

# Simple USB backup script with email notification on error

# === CONFIG ===
SRC="/home/rada/Applications"           # folder to back up
LABEL="Backup"                           # USB drive label
MOUNT_POINT="/mnt/usbbackup"
LOG_FILE="/dev/shm/usb_backup.log"

# Detect the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMAIL_SCRIPT="$SCRIPT_DIR/send_mail.py"

# === SCRIPT ===
echo "[$(date)] Starting backup..." >> "$LOG_FILE"

# Find device by label
DEV=$(blkid -L "$LABEL")
if [ -z "$DEV" ]; then
  MSG="[$(date)] ERROR: USB with label '$LABEL' not found."
  echo "$MSG" >> "$LOG_FILE"
  python3 "$EMAIL_SCRIPT" "$MSG"
  exit 1
fi

# Mount
mkdir -p "$MOUNT_POINT"
mount | grep -q "$MOUNT_POINT" || sudo mount "$DEV" "$MOUNT_POINT"
if [ $? -ne 0 ]; then
  MSG="[$(date)] ERROR: Failed to mount $DEV"
  echo "$MSG" >> "$LOG_FILE"
  python3 "$EMAIL_SCRIPT" "$MSG"
  exit 1
fi

# Perform backup (rsync for efficiency)
rsync -av --delete "$SRC/" "$MOUNT_POINT/backup/" >> "$LOG_FILE" 2>&1
RESULT=$?

# Sync and unmount
sync
sudo umount "$MOUNT_POINT"

if [ $RESULT -eq 0 ]; then
  echo "[$(date)] Backup successful." >> "$LOG_FILE"
else
  MSG="[$(date)] Backup failed (rsync exit code $RESULT)."
  echo "$MSG" >> "$LOG_FILE"
  python3 "$EMAIL_SCRIPT" "$MSG"
fi

python3 "$EMAIL_SCRIPT" "Backup done"