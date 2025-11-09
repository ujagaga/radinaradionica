#!/usr/bin/env bash

SERVICE_NAME=radinaradionica_backup.service
TIMER_NAME=radinaradionica_backup.timer
SERVICE_FILE=/etc/systemd/system/$SERVICE_NAME
TIMER_FILE=/etc/systemd/system/$TIMER_NAME

# --- Installation Section ---
echo "Installing dependencies..."
if ! sudo apt update -y; then
  echo "Error: Failed to update apt repositories. Aborting installation."
  exit 1
fi

if ! sudo apt install -y rsync; then
  echo "Error: Failed to install dependencies. Aborting installation."
  exit 1
fi

echo "Making usb_backup.sh executable..."
chmod +x usb_backup.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to make usb_backup.sh executable. Aborting installation."
  exit 1
fi

# --- Backup Service File Creation ---
echo "Creating systemd service file: $SERVICE_FILE"
cat <<EOF > "$PWD/$SERVICE_NAME"
[Unit]
Description=USB Backup Service
After=local-fs.target

[Service]
Type=oneshot
ExecStart=$PWD/usb_backup.sh
WorkingDirectory=$PWD
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to create the service file. Aborting installation."
  exit 1
fi

sudo mv "$PWD/$SERVICE_NAME" "$SERVICE_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to move the service file to $SERVICE_FILE. Aborting installation."
  exit 1
fi

# --- Timer File Creation ---
echo "Creating systemd timer file: $TIMER_FILE"
cat <<EOF > "$PWD/$TIMER_NAME"
[Unit]
Description=Run USB backup at midnight and noon

[Timer]
OnCalendar=*-*-* 00:00:00
OnCalendar=*-*-* 12:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to create the timer file. Aborting installation."
  exit 1
fi

sudo mv "$PWD/$TIMER_NAME" "$TIMER_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to move the timer file to $TIMER_FILE. Aborting installation."
  exit 1
fi

# --- Enable and Start Timer ---
echo "Enabling and starting the timer..."
sudo systemctl daemon-reload
sudo systemctl enable --now "$TIMER_NAME"
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable and start the timer. Installation incomplete."
  exit 1
fi

echo "Backup service and timer installed successfully!"
echo "Next runs can be checked with: systemctl list-timers --all"

exit 0
