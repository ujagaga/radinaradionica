#!/usr/bin/env bash
# Simple USB restore script

# === CONFIG ===
DEST="/home/rada/Applications"      # folder to restore to
LABEL="Backup"                      # USB drive label
MOUNT_POINT="/mnt/usbbackup"
LOG_FILE="/dev/shm/usb_restore.log"

# === SCRIPT ===
echo "[$(date)] Starting restore..." >> "$LOG_FILE"

# Find device by label
DEV=$(blkid -L "$LABEL")
if [ -z "$DEV" ]; then
  echo "[$(date)] ERROR: USB with label '$LABEL' not found." >> "$LOG_FILE"
  exit 1
fi

# Mount if not already mounted
mkdir -p "$MOUNT_POINT"
mount | grep -q "$MOUNT_POINT" || sudo mount "$DEV" "$MOUNT_POINT"
if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: Failed to mount $DEV" >> "$LOG_FILE"
  exit 1
fi

# Verify backup folder exists
if [ ! -d "$MOUNT_POINT/backup" ]; then
  echo "[$(date)] ERROR: No backup folder found on USB drive." >> "$LOG_FILE"
  sudo umount "$MOUNT_POINT"
  exit 1
fi

# Perform restore (rsync for safety)
# -a : archive mode
# -v : verbose
# --delete : delete files not present on backup (optional)
# Add --dry-run first if you want to preview what will happen
rsync -av --delete "$MOUNT_POINT/backup/" "$DEST/" >> "$LOG_FILE" 2>&1
RESULT=$?

# Sync and unmount
sync
sudo umount "$MOUNT_POINT"

if [ $RESULT -eq 0 ]; then
  echo "[$(date)] Restore successful." >> "$LOG_FILE"
else
  echo "[$(date)] Restore failed (rsync exit code $RESULT)." >> "$LOG_FILE"
fi
